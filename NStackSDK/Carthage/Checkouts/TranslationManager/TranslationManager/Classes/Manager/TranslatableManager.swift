//
//  TranslatableManager.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

// FIXME: Remove Swiftlint disable
// swiftlint:disable file_length

/// The TranslatableManager handles everything related to translations.
public class TranslatableManager<T: Translatable, L: LanguageModel, C: LocalizationModel>: TranslatableManagerType {

    // MARK: - Properties -
    // MARK: Public

    /// The update mode used to determine how translations should update.
    public var updateMode: UpdateMode

    /// The decoder used to decode on-the-fly downloaded translations into models.
    /// By default uses a `.convertFromSnakeCase` for the `keyDecodingStrategy` property,
    /// which you can change if your API works differently.
    public let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// The encoder used to encode on-the-fly downloaded translations into a file that can be loaded
    /// on future starts. By default uses a `.convertToSnakeCase` for the `keyEncodingStrategy` property,
    /// which you can change if your API works differently.
    public let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    /// In memory cache of the current best fit language object.
    public internal(set) var bestFitLanguage: Language? {
        get {
            return userDefaults.codable(forKey: Constants.Keys.currentBestFitLanguage)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.Keys.currentBestFitLanguage)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.Keys.currentBestFitLanguage)
        }
    }

    /// In memory cache of the set default language object.
    public internal(set) var defaultLanguage: Language? {
        get {
            return userDefaults.codable(forKey: Constants.Keys.defaultLanguage)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.Keys.defaultLanguage)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.Keys.defaultLanguage)
        }
    }

    /// Internal handler closure for language change.
    public weak var delegate: TranslatableManagerDelegate?

    /// Returns a string containing the current locale's preferred languages in a prioritized
    /// manner to be used in a accept-language header. If no preferred language available,
    /// fallback language is returned (English). Format example:
    ///
    /// "da;q=1.0,en-gb;q=0.8,en;q=0.7"
    ///
    /// - Returns: An accept language header string.
    public var acceptLanguage: String {
        var components: [String] = []

        // If we should have language override, then append custom language code
        if let languageOverride = languageOverride {
            components.append(languageOverride.identifier + ";q=1.0")
        }

        // Get all languages and calculate lowest quality
        var languages = repository.fetchPreferredLanguages()

        // Append fallback language if we don't have any provided
        if components.isEmpty && languages.isEmpty {
            languages.append("en")
        }

        let startValue = 1.0 - (0.1 * Double(components.count))
        let endValue = startValue - (0.1 * Double(languages.count))

        // Goes through max quality to the lowest (or 0.5, whichever is higher) by 0.1 decrease
        // and appends a component with the language code and quality, like this:
        // en-gb;q=1.0
        for quality in stride(from: startValue, to: max(endValue, 0.5), by: -0.1) {
            components.append("\(languages.removeFirst());q=\(quality)")
        }

        // Joins all components together to get "da;q=1.0,en-gb;q=0.8" string
        return components.joined(separator: ",")
    }

    // MARK: Private

    /// Repository that provides translations.
    fileprivate let repository: TranslationRepository

    /// File manager handling persisting new translation data.
    fileprivate let fileManager: FileManager

    /// User defaults used to store basic information and settings.
    fileprivate let userDefaults: UserDefaults

    /// An observer used to observe application state.
    internal lazy var stateObserver: ApplicationStateObserverType = {
        return ApplicationStateObserver(delegate: self)
    }()

    /// In memory cache of translations objects mapped with their locale id.
    internal var translatableObjectDictonary: [String: Translatable] = [:]

    /// The previous date the localizations were updated
    internal var lastUpdatedDate: Date? {
        get {
            let timeInterval = userDefaults.double(forKey: Constants.Keys.lastUpdatedDate)
            if timeInterval == 0 {
                return nil
            }
            return Date(timeIntervalSince1970: TimeInterval(timeInterval))
        }
        set {
            guard let newValue = newValue else {
                // Last accept header deleted
                userDefaults.removeObject(forKey: Constants.Keys.lastUpdatedDate)
                return
            }
            // Last accept header set to: \(newValue).
            let timeInterval = newValue.timeIntervalSince1970
            userDefaults.set(timeInterval, forKey: Constants.Keys.lastUpdatedDate)
        }
    }

    /// The previous accept header string that was used.
    internal var lastAcceptHeader: String? {
        get {
            return userDefaults.string(forKey: Constants.Keys.previousAcceptLanguage)
        }
        set {
            guard let newValue = newValue else {
                // Last accept header deleted
                userDefaults.removeObject(forKey: Constants.Keys.previousAcceptLanguage)
                return
            }
            // Last accept header set to: \(newValue).
            userDefaults.set(newValue, forKey: Constants.Keys.previousAcceptLanguage)
        }
    }

    /// This locale will be used instead of the phones' language when it is not `nil`. Remember
    /// to call `updateTranslations()` after changing the value.
    /// Otherwise, the effect will not be seen.
    public var languageOverride: Locale? {
        get {
            guard let id = userDefaults.string(forKey: Constants.Keys.languageOverride) else { return nil }
            return Locale(identifier: id)
        }
        set {
            guard let newValue = newValue else {
                // Last accept header deleted
                userDefaults.removeObject(forKey: Constants.Keys.languageOverride)

                //if update mode is automatic update translations, to get new best fit language
                if updateMode == .automatic {
                    updateTranslations()
                }
                return
            }
            // Last accept header set to: \(newValue).
            let id = newValue.identifier
            userDefaults.set(id, forKey: Constants.Keys.languageOverride)

            //if update mode is automatic update translations, to get new best fit language
            if updateMode == .automatic {
                //clear best fit as it may no longer be best fit with new override
                bestFitLanguage = nil
                updateTranslations()
            }
        }
    }

    /// This language will be used when there is no current language set.
    /// We should assure this is always set and is always set to a Locale that the bundle has JSON fallback translations for.
    internal var fallbackLocale: Locale?

    /// The URL used to persist downloaded localizations.
    internal func localizationConfigFileURL() -> URL? {
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        url = url?.appendingPathComponent("Localization", isDirectory: true)
        return url?.appendingPathComponent("LocalizationData.lclfile", isDirectory: false)
    }

    /// The URL used to persist downloaded translations.
    internal func translationsFileUrl(localeId: String) -> URL? {
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        url = url?.appendingPathComponent("Localization", isDirectory: true)
        url = url?.appendingPathComponent("Locales", isDirectory: true)
        return url?.appendingPathComponent("\(localeId).tmfile", isDirectory: false)
    }

    // MARK: - Methods -
    // MARK: Lifecycle

    /// Instantiates and sets the repository from which translations are fetched and update mode
    /// that determines how translations should be updated.
    ///
    /// - Parameters:
    ///   - repository: The repository used to fetch translations and locale/language settings.
    ///   - updateMode: Update mode that determines how should translations be updated. See `UpdateMode`.
    ///   - fileManager: A file manager used to persist downloaded translations and load fallback translations.
    ///   - userDefaults: User defaults that are used to accept headers and language override.
    ///   - fallbackLocale: The locale used when there is no current language set.
    ///     This should be a locale that has fallback translations in the bundle. Defaults to english
    required public init(repository: TranslationRepository,
                         updateMode: UpdateMode = .automatic,
                         fileManager: FileManager = .default,
                         userDefaults: UserDefaults = .standard) {
        // Set the properties
        self.updateMode = updateMode
        self.repository = repository
        self.fileManager = fileManager
        self.userDefaults = userDefaults

        // Start observing state changes
        stateObserver.startObserving()
        parseFallbackJSONTranslations()

        switch updateMode {
        case .automatic:
            // Try updating the translations
            updateTranslations()

        case .manual:
            // Don't do anything on manual update mode
            break
        }
    }

    deinit {
        // Stop observing on deinit
        stateObserver.stopObserving()
    }

    /// Find a translation for a key.
    ///
    /// - Parameters:
    ///   - keyPath: The key that string should be found on.
    public func translation(for keyPath: String) throws -> String? {
        guard !keyPath.isEmpty else {
            return nil
        }

        // Split the key path
        let keys = keyPath.components(separatedBy: ".")

        // Make sure we only have section and key components
        guard keys.count == 2 else {
            throw TranslationError.invalidKeyPath
        }

        let section = keys[0]
        let key = keys[1]

        //first try best fit language, this is returned from backend
        if let currentLangCode = bestFitLanguage?.acceptLanguage {
            //we have a current language
            // Try to load if we don't have any translations
            if translatableObjectDictonary[currentLangCode] == nil {
                do {
                    try createTranslatableObject(currentLangCode, type: T.self)
                } catch {} //continue
            }
            if let translations = translatableObjectDictonary[currentLangCode] {
                return translations[section]?[key]
            }
        }

        //if not, try override locale, if we have this but not best fit its because update translations failed
        if let override = languageOverride?.identifier {
            //we have a current language
            // Try to load if we don't have any translations
            if translatableObjectDictonary[override] == nil {
                do {
                    try createTranslatableObject(override, type: T.self)
                } catch {} //continue
            }
            if let translations = translatableObjectDictonary[override] {
                return translations[section]?[key]
            }
        }

        //no override, try to see if any preferred languages are available
        for lang in repository.fetchPreferredLanguages() {

            if translatableObjectDictonary[lang] == nil {
                do {
                    try createTranslatableObject(lang, type: T.self)
                } catch {
                    continue
                }
            }
            if let translations = translatableObjectDictonary[lang] {
                return translations[section]?[key]
            }
        }

        //if not, try fallback locale
        if let fallback = fallbackLocale?.identifier {
            if translatableObjectDictonary[fallback] == nil {
                do {
                    try createTranslatableObject(fallback, type: T.self)
                } catch {} //continue
            }
            if let translations = translatableObjectDictonary[fallback] {
                return translations[section]?[key]
            }
        }

        //try default language set, from backend/JSON Configs
        if let defaultLanguage = defaultLanguage?.acceptLanguage {
            //we have a current language
            // Try to load if we don't have any translations
            if translatableObjectDictonary[defaultLanguage] == nil {
                do {
                    try createTranslatableObject(defaultLanguage, type: T.self)
                } catch {} //continue
            }
            if let translations = translatableObjectDictonary[defaultLanguage] {
                return translations[section]?[key]
            }
        }

        //if all above failed, just use first value in translations
        return translatableObjectDictonary.first?.value[section]?[key]
    }

    // MARK: Update & Fetch

    /// Parse the fallback JSON versions of the translations and cache them as Translatable objects
    ///
    /// - Parameter completion: Called when translation fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    public func parseFallbackJSONTranslations(_ completion: ((_ error: Error?) -> Void)? = nil) {

        var allJsonURLS: [URL] = []
        for bundle in repository.fetchBundles() {
            if let jsonURLS = bundle.urls(forResourcesWithExtension: ".json", subdirectory: nil) {
                allJsonURLS.append(contentsOf: jsonURLS)
            }
        }

        var translationsURLs: [URL] = []
        for url in allJsonURLS {
            if url.lastPathComponent.contains("Translations") {
                translationsURLs.append(url)
            }
        }

        for url in translationsURLs {
            do {
                let data = try Data(contentsOf: url)
                let translationsData = try decoder.decode(TranslationResponse<Language>.self, from: data)
                self.handleTranslationsResponse(translationsData: translationsData,
                                                completion: completion)
            } catch {
                completion?(error)
                return
            }
        }
    }

    /// Fetches the latest version of the translations config
    ///
    /// - Parameter completion: Called when translation fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    public func updateTranslations(_ completion: ((_ error: Error?) -> Void)? = nil) {

        //check if we've got an override, if not, use default accept language
        let languageAcceptHeader = languageOverride?.identifier ?? acceptLanguage
        repository.getLocalizationConfig(acceptLanguage: languageAcceptHeader,
                                         lastUpdated: lastUpdatedDate)
        { (response: Result<[LocalizationModel]>) in
            switch response {
            case .success(let configs):
                self.lastUpdatedDate = Date()

                //if accept header has changed, update it
                if self.lastAcceptHeader != languageAcceptHeader {
                    //update what the last accept header was that was used
                    self.lastAcceptHeader = languageAcceptHeader
                }

                do {
                    try self.saveLocalizations(localizations: configs)
                } catch {
                    completion?(error)
                    return
                }

                let localizationsThatRequireUpdate = configs.filter({ $0.shouldUpdate == true })
                for localization in localizationsThatRequireUpdate {
                    self.updateLocaleTranslations(localization, completion: completion)
                }
            case .failure(let error):
                //error fetching configs
                completion?(error)
            }
        }
    }

    /// Fetches the latest version of the translations for the locale specified
    ///
    /// - Parameter localization: The locale required to request translations for
    /// - Parameter completion: Called when translation fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    func updateLocaleTranslations(_ localization: LocalizationModel, completion: ((_ error: Error?) -> Void)? = nil) {
        //check if we've got an override, if not, use default accept language
        let languageAcceptHeader = languageOverride?.identifier ?? acceptLanguage

        repository.getTranslations(localization: localization,
                                   acceptLanguage: languageAcceptHeader) { (result: Result<TranslationResponse<Language>>) in

                                    switch result {
                                    case .success(let translationsData):
                                        // New translations downloaded
                                        self.handleTranslationsResponse(translationsData: translationsData,
                                                                   completion: completion)

                                    case .failure(let error):
                                        // Error downloading translations data
                                        completion?(error)

                                    }
            }
    }

    func handleTranslationsResponse(translationsData: TranslationResponse<Language>, completion: ((_ error: Error?) -> Void)? = nil) {
        //cache current best fit language
        if let lang = translationsData.meta?.language {

            //if language is best fit
            if lang.isBestFit {
                if self.bestFitLanguage?.acceptLanguage != lang.acceptLanguage {
                    // Running language changed action, if best fit language is now different
                    self.delegate?.translationManager(languageUpdated: self.bestFitLanguage)
                }
                self.bestFitLanguage = lang
            }

            if lang.isDefault {
                self.defaultLanguage = lang
            }
        }

        do {
            try self.set(response: translationsData, type: .single)
        } catch {
            completion?(error)
            return
        }

        completion?(nil)
    }

    /// Gets the languages for which translations are available.
    ///
    /// - Parameter completion: An Alamofire DataResponse object containing the array or languages on success.
    public func fetchAvailableLanguages<L>(_ completion: @escaping (Result<[L]>) -> Void) where L: LanguageModel {
        // Fetching available language asynchronously
        repository.getAvailableLanguages(completion: completion)
    }

    /// Useful for setting language override, fx. if you want to choose language in the settings of your app.
    ///
    /// - Parameter language: The language you would like to use.
    /// - Throws: A `TranslationError` error if clearing translations fails.
    public func set<L>(languageOverride language: L?) throws where L: LanguageModel {
        if let newValue = language {
            userDefaults.setCodable(newValue, forKey: Constants.Keys.languageOverride)
        } else {
            userDefaults.removeObject(forKey: Constants.Keys.languageOverride)
        }
    }

    // MARK: Translations

    /// The parsed translations object is cached in memory, but persisted as a dictionary.
    /// If a persisted version cannot be found, the fallback json file in the bundle will be used.
    ///
    /// - Returns: A translations object.
    public func translations<T: Translatable>(localeId: String) throws -> T? {
        // Check object in memory
        if let cachedObject = translatableObjectDictonary[localeId] as? T {
            return cachedObject
        }

        // Load persisted or fallback translations
        try createTranslatableObject(localeId, type: T.self)

        // Now we must have correct translations, so return it
        return translatableObjectDictonary[localeId] as? T
    }

    /// Clears both the memory and persistent cache. Used for debugging purposes.
    ///
    /// - Parameter includingPersisted: If set to `true`, local persisted translation
    ///                                 file will be deleted.
    public func clearTranslations(includingPersisted: Bool = false) throws {
        // In memory translations cleared
        translatableObjectDictonary.removeAll()

        if includingPersisted {
            try deletePersistedTranslations()
        }
    }

    /// Loads and initializes the translations object from either persisted or fallback dictionary.
    func createTranslatableObject<T>(_ localeId: String, type: T.Type) throws where T: Translatable {
        let translations: TranslationResponse<Language>
        var shouldUnwrapTranslation = false

        //try to use persisted translations for locale
        if let persisted = try persistedTranslations(localeId: localeId),
            let typeString = userDefaults.string(forKey: Constants.Keys.persistedTranslationType),
            let translationType = PersistedTranslationType(rawValue: typeString) {
            translations = persisted
            shouldUnwrapTranslation = translationType == .all // only unwrap when all translations are stored

        } else {
            //otherwise search for fallback
            translations = try fallbackTranslations(localeId: localeId)
        }

        // Figure out and set translations
        guard let parsed = try processAllTranslations(translations, shouldUnwrap: shouldUnwrapTranslation)  else {
            translatableObjectDictonary.removeValue(forKey: localeId)
            return
        }

        let data = try JSONSerialization.data(withJSONObject: parsed, options: [])
        translatableObjectDictonary[localeId] = try decoder.decode(T.self, from: data)
    }

    // MARK: Dictionaries

    /// Saves the localization config set.
    ///
    /// - Parameter [Localizations]: The current Localizations available.
    public func saveLocalizations(localizations: [LocalizationModel]) throws {
        guard let configFileUrl = localizationConfigFileURL() else {
            throw TranslationError.localizationsConfigFileUrlUnavailable
        }
        var configModels: [LocalizationConfig] = []
        for localize in localizations {
            let config = LocalizationConfig(lastUpdatedAt: Date(), localeIdentifier: localize.localeIdentifier, shouldUpdate: localize.shouldUpdate)
            configModels.append(config)
        }

        // Get encoded data
        let data = try encoder.encode(configModels)
        createDirIfNeeded(dirName: "Localization")

        try data.write(to: configFileUrl, options: [.atomic])
    }

    func createDirIfNeeded(dirName: String) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(dirName + "/")
        do {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Saves the translations set.
    ///
    /// - Parameter translations: The new translations.
    public func set<L>(response: TranslationResponse<L>, type: PersistedTranslationType) throws where L: LanguageModel {
        guard let locale = response.meta?.language?.locale.identifier else {
            throw TranslationError.translationsFileUrlUnavailable
        }

        guard let translationsFileUrl = translationsFileUrl(localeId: locale) else {
            throw TranslationError.translationsFileUrlUnavailable
        }

        // Get encoded data
        let data = try encoder.encode(response)

        //create directory if needed
        createDirIfNeeded(dirName: "Localization")
        createDirIfNeeded(dirName: "Localization/Locales")

        // Save to disk
        try data.write(to: translationsFileUrl, options: [.atomic])

        // Exclude from backup
        try excludeUrlFromBackup(translationsFileUrl)

        // Save type of persisted translations
        userDefaults.set(type.rawValue, forKey: Constants.Keys.persistedTranslationType)

        // Reload the translations
        try createTranslatableObject(locale, type: T.self)
    }

    internal func deletePersistedTranslations() throws {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Localization/Locales")

        //get all filepaths in locale directory
        let filePaths = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])

        //remove all files in this directory
        for path in filePaths {
            try fileManager.removeItem(at: path)
        }
    }

    /// Translations that were downloaded and persisted on disk.
    internal func persistedTranslations(localeId: String) throws -> TranslationResponse<Language>? {
        // Getting persisted traslations
        guard let url = translationsFileUrl(localeId: localeId) else {
            throw TranslationError.translationsFileUrlUnavailable
        }

        // If file doesn't exist, return nil
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        // If downloaded data is corrupted or wrong, try and delete it
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(TranslationResponse<Language>.self, from: data)
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
    /// - Returns: A dictionary representation of the selected local translations set.
    internal func fallbackTranslations(localeId: String) throws -> TranslationResponse<Language> {
        // Iterate through bundle until we find the translations file
        for bundle in repository.fetchBundles() {
            // Check if bundle contains translations file, otheriwse continue with next bundle
            guard let filePath = bundle.path(forResource: "Translations_\(localeId)", ofType: "json") else {
                continue
            }

            let fileUrl = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: fileUrl)
            return try decoder.decode(TranslationResponse<Language>.self, from: data)
        }

        // Failed to load fallback translations, file non-existent
        throw TranslationError.loadingFallbackTranslationsFailed
    }

    internal func excludeUrlFromBackup(_ url: URL) throws {
        var mutableUrl = url
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try mutableUrl.setResourceValues(resourceValues)
    }

    // MARK: Parsing

    /// Unwraps and extracts proper language dictionary out of the dictionary containing
    /// all translations.
    ///
    /// - Parameter dictionary: Dictionary containing all translations under the `data` key.
    /// - Returns: Returns extracted language dictioanry for current accept language.
    internal func processAllTranslations(_ object: TranslationResponse<Language>, shouldUnwrap: Bool) throws -> [String: Any]? {
        // Processing translations dictionary
        guard !object.translations.isEmpty else {
            // Failed to get data from all translations dictionary
            throw TranslationError.noTranslationsFound
        }

        if shouldUnwrap {
            return try extractLanguageDictionary(fromDictionary: object.translations)
        } else {
            return object.translations
        }
    }

    /// Uses the device's current locale to select the appropriate translations set.
    ///
    /// - Parameter json: A dictionary containing translation sets by language code key.
    /// - Returns: A translations set as a dictionary.
    internal func extractLanguageDictionary(fromDictionary dictionary: [String: Any]) throws -> [String: Any] {
        // Extracting language dictionary
        var languageDictionary: [String: Any]?

        // First try overriden language
        if let languageOverride = languageOverride,
            let dictionary = translationsMatching(localeId: languageOverride.identifier, inDictionary: dictionary) {
            return dictionary
        }

        let languages = repository.fetchPreferredLanguages()
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
            if let dictionary = translationsMatching(locale: lanShort, inDictionary: dictionary) {
                // Found matching language for short language code
                return dictionary
            }
        }

        // Take preferred language from backend
        if let currentLanguage = bestFitLanguage,
            let languageDictionary = translationsMatching(locale: currentLanguage.locale.identifier,
                                                          inDictionary: dictionary) {
            // Finding translations for language recommended by API
            return languageDictionary
        }

        // Falling back to first language in dictionary
        languageDictionary = dictionary.values.first as? [String: Any]

        if let languageDictionary = languageDictionary {
            return languageDictionary
        }

        // Error loading translations. No translations available
        throw TranslationError.noTranslationsFound
    }

    /// Searches the translation file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - language: The desired language. If `nil`, first language will be used.
    ///   - json: The dictionary containing translations for all languages.
    /// - Returns: Translations dictionary for the given language.
    internal func translationsMatching(localeId: String, inDictionary dictionary: [String: Any]) -> [String: Any]? {
        return translationsMatching(locale: localeId, inDictionary: dictionary)
    }

    /// Searches the translation file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - locale: A language code of the desired language.
    ///   - json: The dictionary containing translations for all languages.
    /// - Returns: Translations dictionary for the given language.
    internal func translationsMatching(locale: String, inDictionary dictionary: [String: Any]) -> [String: Any]? {
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

// MARK: - ApplicationStateObserverDelegate

extension TranslatableManager: ApplicationStateObserverDelegate {
    func applicationStateHasChanged(_ state: ApplicationState) {
        switch state {
        case .foreground:
            // Update translations when we go to foreground and update mode is automatic
            switch updateMode {
            case .automatic:
                updateTranslations()

            case .manual:
                // Don't do anything on manual update mode
                break
            }

        case .background:
            // Do nothing when we go to background
            break
        }
    }
}
