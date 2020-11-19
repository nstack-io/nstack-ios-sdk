//
//  TranslatableManager.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

// FIXME: Remove Swiftlint disable
// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// The LocalizationManager handles everything related to localizations.
public class LocalizationManager<Language, Descriptor: LocalizationDescriptor> where Descriptor.LanguageType == Language {

    // MARK: - Properties -

    /// The Type of Localizable model that is used to decode localizations
    /// This should be the generated LocalizableModel class from the LocalizationsGenerator
    var localizableModel: LocalizableModel.Type

    /// The update mode used to determine how localizations should update.
    public var updateMode: UpdateMode

    /// The decoder used to decode on-the-fly downloaded localizations into models.
    public let decoder = JSONDecoder()

    /// The encoder used to encode on-the-fly downloaded localizations into a file
    /// that can be loaded on future starts.
    public let encoder = JSONEncoder()

    /// In memory cache of the current best fit language object.
    public internal(set) var bestFitLanguage: Language? {
        get {
            return userDefaults.codable(forKey: Constants.LocalizationManagerKeys.currentBestFitLanguage)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.LocalizationManagerKeys.currentBestFitLanguage)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.LocalizationManagerKeys.currentBestFitLanguage)
        }
    }

    /// In memory cache of the set default language object.
    public internal(set) var defaultLanguage: Language? {
        get {
            return userDefaults.codable(forKey: Constants.LocalizationManagerKeys.defaultLanguage)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.LocalizationManagerKeys.defaultLanguage)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.LocalizationManagerKeys.defaultLanguage)
        }
    }

    /// Internal handler closure for language change.
    public weak var delegate: LocalizationManagerDelegate?

    /// Responsible for providing the accept language header string.
    internal let acceptLanguageProvider: AcceptLanguageProviderType

    // MARK: Private

    /// Repository that provides localizations.
    fileprivate let repository: LocalizationRepository

    /// Repository that context for localization, like preferred languages or bundles.
    fileprivate let contextRepository: LocalizationContextRepository

    /// File manager handling persisting new localization
    fileprivate let fileManager: FileManager

    /// User defaults used to store basic information and settings.
    fileprivate let userDefaults: UserDefaults

    /// An observer used to observe application state.
    internal lazy var stateObserver: ApplicationStateObserverType = {
        return ApplicationStateObserver(delegate: self)
    }()

    /// In memory cache of localizations objects mapped with their locale id.
    internal var localizableObjectDictonary: [String: LocalizableModel] = [:]

    /// In memory cache of langauge objects
    internal var availableLanguages: [Language] {
        get {
            return userDefaults.codable(forKey: Constants.LocalizationManagerKeys.availableLanguages) ?? []
        }
        set {
            userDefaults.setCodable(newValue, forKey: Constants.LocalizationManagerKeys.availableLanguages)
        }
    }

    /// The previous date the localizations were updated
    internal var lastUpdatedDate: Date? {
        get {
            let timeInterval = userDefaults.double(forKey: Constants.LocalizationManagerKeys.lastUpdatedDate)
            if timeInterval == 0 {
                return nil
            }
            return Date(timeIntervalSince1970: TimeInterval(timeInterval))
        }
        set {
            guard let newValue = newValue else {
                // Last accept header deleted
                userDefaults.removeObject(forKey: Constants.LocalizationManagerKeys.lastUpdatedDate)
                return
            }
            // Last accept header set to: \(newValue).
            let timeInterval = newValue.timeIntervalSince1970
            userDefaults.set(timeInterval, forKey: Constants.LocalizationManagerKeys.lastUpdatedDate)
        }
    }

    /// The previous accept header string that was used.
    internal var lastAcceptHeader: String? {
        get {
            return userDefaults.string(forKey: Constants.LocalizationManagerKeys.previousAcceptLanguage)
        }
        set {
            guard let newValue = newValue else {
                // Last accept header deleted
                userDefaults.removeObject(forKey: Constants.LocalizationManagerKeys.previousAcceptLanguage)
                return
            }
            // Last accept header set to: \(newValue).
            userDefaults.set(newValue, forKey: Constants.LocalizationManagerKeys.previousAcceptLanguage)
        }
    }

    /// This locale will be used instead of the phones' language when it is not `nil`.
    /// Remember to call `updateLocalizations()` after changing the value, otherwise the
    /// effect will not be seen.
    public var languageOverride: Language? {
        get {
            return userDefaults.codable(forKey: Constants.LocalizationManagerKeys.languageOverride)
        }
        set {
            guard let newValue = newValue else {
                // Last accept header deleted
                userDefaults.removeObject(forKey: Constants.LocalizationManagerKeys.languageOverride)
                updateLocalizations()
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.LocalizationManagerKeys.languageOverride)

            bestFitLanguage = nil
            updateLocalizations()
        }
    }

    /// This language will be used when there is no current language set.
    /// We should assure this is always set and is always set to a Locale that the bundle has JSON fallback localizations for.
    internal var fallbackLocale: Locale?

    /// The URL used to persist downloaded localizations.
    internal func localizationConfigFileURL() -> URL? {
        #if os(tvOS)
            var url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        #else
            var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        #endif

        url = url?.appendingPathComponent("Localization", isDirectory: true)
        return url?.appendingPathComponent("LocalizationData.lclfile", isDirectory: false)
    }

    /// The URL used to persist downloaded localizations.
    internal func localizationFileUrl(localeId: String) -> URL? {
        #if os(tvOS)
            var url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        #else
            var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        #endif
        url = url?.appendingPathComponent("Localization", isDirectory: true)
        url = url?.appendingPathComponent("Locales", isDirectory: true)
        return url?.appendingPathComponent("\(localeId).tmfile", isDirectory: false)
    }

    // MARK: - Methods -
    // MARK: Lifecycle

    /// Instantiates and sets the repository from which localizations are fetched and update mode
    /// that determines how localizations should be updated.
    ///
    /// - Parameters:
    ///   - repository: The repository used to fetch localizations and locale/language settings.
    ///   - updateMode: Update mode that determines how should localizations be updated. See `UpdateMode`.
    ///   - fileManager: A file manager used to persist downloaded localizations and load fallback localizations.
    ///   - userDefaults: User defaults that are used to accept headers and language override.
    ///   - fallbackLocale: The locale used when there is no current language set.
    ///     This should be a locale that has fallback localizations in the bundle. Defaults to english
    required public init(repository: LocalizationRepository,
                         contextRepository: LocalizationContextRepository,
                         localizableModel: LocalizableModel.Type,
                         updateMode: UpdateMode = .automatic,
                         fileManager: FileManager = .default,
                         userDefaults: UserDefaults = .standard) {
        // Set the properties
        self.updateMode = updateMode
        self.localizableModel = localizableModel
        self.repository = repository
        self.contextRepository = contextRepository
        self.fileManager = fileManager
        self.userDefaults = userDefaults
        self.acceptLanguageProvider = AcceptLanguageProvider(repository: contextRepository)

        // Start observing state changes
        stateObserver.startObserving()

        // Load persisted or fallback translations
        if (try? localization()) == nil {
            parseFallbackJSONLocalizations()
        }

        switch updateMode {
        case .automatic:
            // Try updating the localizations
            updateLocalizations()

        case .manual:
            // Don't do anything on manual update mode
            break
        }
    }

    deinit {
        // Stop observing on deinit
        stateObserver.stopObserving()
    }

    /// Find a localization for a key.
    ///
    /// - Parameters:
    ///   - keyPath: The key that string should be found on.
    // swiftlint:disable:next cyclomatic_complexity
    public func localization(for keyPath: String) throws -> String? {
        guard !keyPath.isEmpty else {
            return nil
        }

        // Split the key path
        let keys = keyPath.components(separatedBy: ".")

        // Make sure we only have section and key components
        guard keys.count == 2 else {
            throw LocalizationError.invalidKeyPath
        }

        let section = keys[0]
        let key = keys[1]

        //first try best fit language, this is returned from backend
        if let currentLangCode = bestFitLanguage?.locale.identifier {
            //we have a current language
            // Try to load if we don't have any localizations
            if localizableObjectDictonary[currentLangCode] == nil {
                do {
                    try createLocalizationObject(currentLangCode)
                } catch {} //continue
            }
            if let localizations = localizableObjectDictonary[currentLangCode] {
                return localizations[section]?[key]
            }
        }

        //if not, try override locale, if we have this but not best fit its because update localizations failed
        if let override = languageOverride?.locale.identifier {
            //we have a current language
            // Try to load if we don't have any localizations
            if localizableObjectDictonary[override] == nil {
                do {
                    try createLocalizationObject(override)
                } catch {} //continue
            }
            if let localizations = localizableObjectDictonary[override] {
                return localizations[section]?[key]
            }
        }

        //no override, try to see if any preferred languages are available
        for lang in contextRepository.fetchPreferredLanguages() {

            if localizableObjectDictonary[lang] == nil {
                do {
                    try createLocalizationObject(lang)
                } catch {
                    continue
                }
            }
            if let localizations = localizableObjectDictonary[lang] {
                return localizations[section]?[key]
            }
        }

        //if not, try fallback locale
        if let fallback = fallbackLocale?.identifier {
            if localizableObjectDictonary[fallback] == nil {
                do {
                    try createLocalizationObject(fallback)
                } catch {} //continue
            }
            if let localizations = localizableObjectDictonary[fallback] {
                return localizations[section]?[key]
            }
        }

        //try default language set, from backend/JSON Configs
        if let defaultLanguage = defaultLanguage?.locale.identifier {
            //we have a current language
            // Try to load if we don't have any localizations
            if localizableObjectDictonary[defaultLanguage] == nil {
                do {
                    try createLocalizationObject(defaultLanguage)
                } catch {} //continue
            }
            if let localizations = localizableObjectDictonary[defaultLanguage] {
                return localizations[section]?[key]
            }
        }

        //if all above failed, just use first value in localizations
        return localizableObjectDictonary.first?.value[section]?[key]
    }

    // MARK: Update & Fetch

    /// Parse the fallback JSON versions of the localizations and cache them as Translatable objects
    ///
    /// - Parameter completion: Called when localization fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    internal func parseFallbackJSONLocalizations(_ completion: ((_ error: Error?) -> Void)? = nil) {

        var allJsonURLS: [URL] = []
        for bundle in contextRepository.getLocalizationBundles() {
            if let jsonURLS = bundle.urls(forResourcesWithExtension: ".json", subdirectory: nil) {
                allJsonURLS.append(contentsOf: jsonURLS)
            }
        }

        var localizationsURLs: [URL] = []
        for url in allJsonURLS {
            if url.lastPathComponent.contains("Localizations") {
                localizationsURLs.append(url)
            }
        }

        for url in localizationsURLs {
            do {
                let data = try Data(contentsOf: url)
                let localizationsData = try decoder.decode(LocalizationResponse<Language>.self, from: data)
                self.handleLocalizationsResponse(localizationsData: localizationsData,
                                                handleMeta: true,
                                                completion: completion)
            } catch {
                completion?(error)
                return
            }
        }
    }

    /// Fetches the latest version of the localizations config
    ///
    /// - Parameter completion: Called when localization fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    public func updateLocalizations(_ completion: ((_ error: Error?) -> Void)? = nil) {

        //check if we've got an override, if not, use default accept language
        let languageAcceptHeader = acceptLanguageProvider.createHeaderString(languageOverride: languageOverride?.locale)
        repository.getLocalizationDescriptors(
            acceptLanguage: languageAcceptHeader,
            lastUpdated: lastUpdatedDate
        ) { (response: Result<[Descriptor]>) in
            switch response {
            case .success(let configs):
                self.handleLocalizationModels(
                    descriptors: configs,
                    acceptHeaderUsed: languageAcceptHeader,
                    completion: completion)

            case .failure(let error):
                //error fetching configs
                completion?(error)
            }
        }
    }

    public func handleLocalizationModels<D: LocalizationDescriptor>(
        descriptors: [D],
        acceptHeaderUsed: String?,
        completion: ((_ error: Error?) -> Void)? = nil
        ) {
        self.lastUpdatedDate = Date()

        //if accept header has changed, update it
        if self.lastAcceptHeader != acceptHeaderUsed {
            //update what the last accept header was that was used
            self.lastAcceptHeader = acceptHeaderUsed
        }

        do {
            try self.saveLocalizationDescriptors(descriptors)
        } catch {
            completion?(error)
            return
        }

        if let bestFit = descriptors.filter({ $0.language.isBestFit }).first {
            if self.bestFitLanguage?.locale.identifier != bestFit.language.locale.identifier {
                // Running language changed action, if best fit language is now different
                self.delegate?.localizationManager(languageUpdated: bestFit.language)
            }
            self.bestFitLanguage = bestFit.language as? Language
        }

        if let defaultLang = descriptors.filter({ $0.language.isDefault }).first {
            self.defaultLanguage = defaultLang.language as? Language
        }

        self.availableLanguages = descriptors.map({ $0.language as! Language })

        let descriptorsThatRequireUpdate = descriptors.filter({ $0.shouldUpdate == true })

        //Once all localizations has been updated, we're safe to call the completion
        //so we use a DispatchGroup for this and then call `leave` where adequate
        let group = DispatchGroup()
        for descriptor in descriptorsThatRequireUpdate {
            updateLocaleLocalization(
                descriptor: descriptor,
                in: group,
                completion: completion
            )
        }
        group.notify(queue: .main) {
            completion?(nil)
        }
    }

    /// Fetches the latest version of the localizations for the locale specified
    ///
    /// - Parameter localization: The locale required to request localizations for
    /// - Parameter completion: Called when localization fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    internal func updateLocaleLocalization<D: LocalizationDescriptor>(
        descriptor: D,
        in group: DispatchGroup,
        completion: ((_ error: Error?) -> Void)? = nil
        ) {
        group.enter()

        //check if we've got an override, if not, use default accept language
        let acceptLanguage = acceptLanguageProvider.createHeaderString(languageOverride: languageOverride?.locale)
        repository.getLocalization(descriptor: descriptor,
                                   acceptLanguage: acceptLanguage) { (result: Result<LocalizationResponse<Language>>) in

            defer {
                group.leave()
            }

            switch result {
            case .success(let localizationsData):
                // New localizations downloaded
                self.handleLocalizationsResponse(localizationsData: localizationsData,
                                                 in: group,
                                                 completion: completion)

            case .failure(let error):
                // Error downloading localizations data
                completion?(error)
            }

        }

    }

    internal func handleLocalizationsResponse(
        localizationsData: LocalizationResponse<Language>,
        handleMeta: Bool = false,
        in group: DispatchGroup? = nil,
        completion: ((_ error: Error?) -> Void)? = nil
        ) {

        group?.enter()

        defer {
            //we're done with this async call, so lets leave
            group?.leave()
        }

        //cache current best fit language
        if handleMeta {
            if let lang = localizationsData.meta?.language {

                //if language is best fit
                if lang.isBestFit {
                    if self.bestFitLanguage?.locale.identifier != lang.locale.identifier {
                        // Running language changed action, if best fit language is now different
                        self.delegate?.localizationManager(languageUpdated: lang)
                    }
                    self.bestFitLanguage = lang
                }

                if lang.isDefault {
                    self.defaultLanguage = lang
                }
            }
        }

        do {
            try self.set(response: localizationsData, type: .single)
        } catch {
            completion?(error)
            return
        }
    }

    /// Gets the languages for which localizations are available.
    ///
    /// - Parameter completion: An completion object containing the array or languages either fetched or cached.
    public func fetchAvailableLanguages(completion: @escaping (([Language]) -> Void)) {
        // Fetching available language asynchronously
        repository.getAvailableLanguages { (result: Result<[Language]>) in
          switch result {
          case .success(let languages):
            //if we dont have any, the call failed, we return what we know
            if languages.isEmpty {
                completion(self.availableLanguages)
                return
            }
            self.updateAvailableLanguages(languages: languages)

            //we can return self.available languages here as they will have been updated by the previous function if all were available
            //if not we only return what we know we have
            completion(self.availableLanguages)
          case .failure:
            completion(self.availableLanguages)
          }
        }
    }

    //if languages have been fetched and do not align with the current translations available, update translations again
    private func updateAvailableLanguages(languages: [Language]) {
        for lang in languages {
            //we dont have translations for a particular fetched langauge, update to fetch what we need
            if !localizableObjectDictonary.keys.contains(lang.locale.identifier) {
                self.updateLocalizations()
                return
            }
        }

        //we've made it here so we have translations for all available languages
        self.availableLanguages = languages
    }

    // MARK: Localizations

    /// The parsed localizations object is cached in memory, but persisted as a dictionary.
    /// If a persisted version cannot be found, the fallback json file in the bundle will be used.
    ///
    /// - Returns: A localizations object.
    public func localization<T: LocalizableModel>(localeId: String? = nil) throws -> T {
        guard let locale = localeId ?? bestFitLanguage?.locale.identifier
            ?? languageOverride?.locale.identifier
            ?? getAvailablePreferredLanguageLocale()
            ?? fallbackLocale?.identifier
            ?? defaultLanguage?.locale.identifier
        else {
            let translatableObjectArray = Array(localizableObjectDictonary.values)
            if let to = translatableObjectArray.first as? T {
                return to
            } else {
                //no locales known, no translatableObjectDictonaries decodable to defined LocalizbleModel type
                throw LocalizationError.noLocaleFound
            }
        }
        // Check object in memory
        if let cachedObject = localizableObjectDictonary[locale] as? T {
            return cachedObject
        }

        // Load persisted or fallback localizations
        try createLocalizationObject(locale)

        // Now we must have correct localizations, so return it
        if let to = localizableObjectDictonary[locale] as? T {
            return to
        } else {
            //no translatableObjectDictonaries decodable to defined LocalizbleModel type
            throw LocalizationError.noLocalizationsFound
        }
    }

    private func getAvailablePreferredLanguageLocale() -> String? {
        for lang in contextRepository.fetchPreferredLanguages() {
            for key in localizableObjectDictonary.keys {
                if key.contains(lang) {
                    return key
                }
            }
        }
        return nil
    }

    /// Clears both the memory and persistent cache. Used for debugging purposes.
    ///
    /// - Parameter includingPersisted: If set to `true`, local persisted localization
    ///                                 file will be deleted.
    public func clearLocalizations(includingPersisted: Bool = false) throws {
        // In memory localizations cleared
        localizableObjectDictonary.removeAll()

        if includingPersisted {
            try deletePersistedLocalizations()
        }
    }

    /// Loads and initializes the localizations object from either persisted or fallback dictionary.
    func createLocalizationObject(_ localeId: String) throws {
        let localization: LocalizationResponse<Language>
        var shouldUnwrapLocalization = false

        //try to use persisted localizations for locale
        if let persisted = try persistedLocalization(localeId: localeId),
            let typeString = userDefaults.string(forKey: Constants.LocalizationManagerKeys.persistedLocalizationType),
            let localizationType = PersistedLocalizationType(rawValue: typeString) {
            localization = persisted
            shouldUnwrapLocalization = localizationType == .all // only unwrap when all localizations are stored

        } else {
            //otherwise search for fallback
            localization = try fallbackLocalization(localeId: localeId)
        }

        // Figure out and set localizations
        guard let parsed = try processAllLocalizations(localization, shouldUnwrap: shouldUnwrapLocalization)  else {
            localizableObjectDictonary.removeValue(forKey: localeId)
            return
        }

        let data = try JSONSerialization.data(withJSONObject: parsed, options: [])
        localizableObjectDictonary[localeId] = try decoder.decode(localizableModel, from: data)
    }

    // MARK: Dictionaries

    /// Saves the localization config set.
    ///
    /// - Parameter [Localizations]: The current Localizations available.
    public func saveLocalizationDescriptors<D: LocalizationDescriptor>(_ descriptors: [D]) throws {
        guard let configFileUrl = localizationConfigFileURL() else {
            throw LocalizationError.localizationsConfigFileUrlUnavailable
        }

        // Get encoded data
        let data = try encoder.encode(descriptors)
        createDirIfNeeded(dirName: "Localization")

        try data.write(to: configFileUrl, options: [.atomic])
    }

    func createDirIfNeeded(dirName: String) {
        #if os(tvOS)
        let dir = FileManager.default.urls(for: .cachesDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(dirName + "/")
        #else
        let dir = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(dirName + "/")
        #endif

        do {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Saves the localizations set.
    ///
    /// - Parameter localizations: The new localizations.
    public func set<L>(response: LocalizationResponse<L>, type: PersistedLocalizationType) throws where L: LanguageModel {
        guard let locale = response.meta?.language?.locale.identifier else {
            throw LocalizationError.localizationFileUrlUnavailable
        }

        guard let localizationsFileUrl = localizationFileUrl(localeId: locale) else {
            throw LocalizationError.localizationFileUrlUnavailable
        }

        // Get encoded data
        let data = try encoder.encode(response)

        //create directory if needed
        createDirIfNeeded(dirName: "Localization")
        createDirIfNeeded(dirName: "Localization/Locales")

        // Save to disk
        try data.write(to: localizationsFileUrl, options: [.atomic])

        // Exclude from backup
        try excludeUrlFromBackup(localizationsFileUrl)

        // Save type of persisted localizations
        userDefaults.set(type.rawValue, forKey: Constants.LocalizationManagerKeys.persistedLocalizationType)

        // Reload the localizations
        try createLocalizationObject(locale)
    }

    internal func deletePersistedLocalizations() throws {
        #if os(tvOS)
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Localization/Locales")
        #else
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Localization/Locales")
        #endif

        //get all filepaths in locale directory
        let filePaths = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])

        //remove all files in this directory
        for path in filePaths {
            try fileManager.removeItem(at: path)
        }
    }

    /// Localizations that were downloaded and persisted on disk.
    internal func persistedLocalization(localeId: String) throws -> LocalizationResponse<Language>? {
        // Getting persisted traslations
        guard let url = localizationFileUrl(localeId: localeId) else {
            throw LocalizationError.localizationFileUrlUnavailable
        }

        // If file doesn't exist, return nil
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        // If downloaded data is corrupted or wrong, try and delete it
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(LocalizationResponse<Language>.self, from: data)
        } catch {
            // Try deleting the file
            if fileManager.isDeletableFile(atPath: url.path) {
                try? fileManager.removeItem(at: url)
            }
            return nil
        }
    }

    /// Loads the local JSON copy, has a return value so that it can be synchronously
    /// loaded the first time they're needed.
    ///
    /// - Returns: A dictionary representation of the selected local localizations set.
    internal func fallbackLocalization(localeId: String) throws -> LocalizationResponse<Language> {
        // Iterate through bundle until we find the localizations file
        for bundle: Bundle in [Bundle(for: localizableModel.self)] + contextRepository.getLocalizationBundles() {
            // Check if bundle contains localizations file, otheriwse continue with next bundle
            guard let filePath = bundle.path(forResource: "Localizations_\(localeId)", ofType: "json") else {
                continue
            }

            let fileUrl = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: fileUrl)
            return try decoder.decode(LocalizationResponse<Language>.self, from: data)
        }

        // Failed to load fallback localizations, file non-existent
        throw LocalizationError.loadingFallbackLocalizationsFailed
    }

    internal func excludeUrlFromBackup(_ url: URL) throws {
        var mutableUrl = url
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try mutableUrl.setResourceValues(resourceValues)
    }

    // MARK: Parsing

    /// Unwraps and extracts proper language dictionary out of the dictionary containing
    /// all localizations.
    ///
    /// - Parameter dictionary: Dictionary containing all localizations under the `data` key.
    /// - Returns: Returns extracted language dictioanry for current accept language.
    internal func processAllLocalizations(_ object: LocalizationResponse<Language>, shouldUnwrap: Bool) throws -> [String: Any]? {
        // Processing localizations dictionary
        guard !object.localization.isEmpty else {
            // Failed to get data from all localizations dictionary
            throw LocalizationError.noLocalizationsFound
        }

        if shouldUnwrap {
            return try extractLanguageDictionary(fromDictionary: object.localization)
        } else {
            return object.localization
        }
    }

    /// Uses the device's current locale to select the appropriate localizations set.
    ///
    /// - Parameter json: A dictionary containing localization sets by language code key.
    /// - Returns: A localizations set as a dictionary.
    internal func extractLanguageDictionary(fromDictionary dictionary: [String: Any]) throws -> [String: Any] {
        // Extracting language dictionary
        var languageDictionary: [String: Any]?

        // First try overriden language
        if let languageOverride = languageOverride,
            let dictionary = localizationMatching(localeId: languageOverride.locale.identifier,
                                                  inDictionary: dictionary) {
            return dictionary
        }

        let languages = contextRepository.fetchPreferredLanguages()
        // Finding language for matching preferred languages

        // Find matching language and region
        for lan in languages {
            // Try matching on both language and region
            if let dictionary = dictionary[lan] as? [String: Any] {
                // Found matching language for language with region
                return dictionary
            }
        }

        let shortLanguages = languages.map({ $0.substring(to: 2) })
        // Finding language for matching preferred  short languages

        // Find matching language only
        for lanShort in shortLanguages {
            // Match just on language
            if let dictionary = localizationMatching(locale: lanShort, inDictionary: dictionary) {
                // Found matching language for short language code
                return dictionary
            }
        }

        // Take preferred language from backend
        if let currentLanguage = bestFitLanguage,
            let languageDictionary = localizationMatching(locale: currentLanguage.locale.identifier,
                                                          inDictionary: dictionary) {
            // Finding localizations for language recommended by API
            return languageDictionary
        }

        // Falling back to first language in dictionary
        languageDictionary = dictionary.values.first as? [String: Any]

        if let languageDictionary = languageDictionary {
            return languageDictionary
        }

        // Error loading localizations. No localizations available
        throw LocalizationError.noLocalizationsFound
    }

    /// Searches the localization file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - language: The desired language. If `nil`, first language will be used.
    ///   - json: The dictionary containing localizations for all languages.
    /// - Returns: Localizations dictionary for the given language.
    internal func localizationMatching(localeId: String, inDictionary dictionary: [String: Any]) -> [String: Any]? {
        return localizationMatching(locale: localeId, inDictionary: dictionary)
    }

    /// Searches the localization file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - locale: A language code of the desired language.
    ///   - json: The dictionary containing localizations for all languages.
    /// - Returns: Localizations dictionary for the given language.
    internal func localizationMatching(locale: String, inDictionary dictionary: [String: Any]) -> [String: Any]? {
        // If we have perfect match on language and region
        if let dictionary = dictionary[locale] as? [String: Any] {
            return dictionary
        }

        // Try shortening keys in dictionary
        for key in dictionary.keys {
            if key.substring(to: 2) == locale {
                return dictionary[key] as? [String: Any]
            }
        }

        return nil
    }
}
