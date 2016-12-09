//
//  TranslationsManager.swift
//  NStack
//
//  Created by Chris Combs on 08/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//
import Foundation
import Serpent
import Cashier
import Alamofire

/// The Translations Manager handles everything related to translations.
///
/// Usually, direct interaction with the `Translations Manager` shouldn't be neccessary, since
/// it is setup automatically by the NStack manager, and the translations are accessible by the
/// global 'tr' variable defined in the auto-generated translations Swift file.
public class TranslationManager {

    /// Repository that provides translations.
    let repository: TranslationsRepository

    /// The translations object type.
    let translationsType: Translatable.Type

    /// Persistent store to use to store information.
    let store: NOPersistentStore

    /// File manager handling persisting new translation data.
    let fileManager: FileManager

    /// Logger used to log valuable information.
    let logger: LoggerType

    /// In memory cache of the translations object.
    var translationsObject: Translatable?

    /// Internal handler closure for language change.
    var languageChangedAction: (() -> Void)?

    /// The previous accept header string that was used.
    var lastAcceptHeader: String? {
        get {
            return store.string(forKey: Constants.CacheKeys.prevAcceptedLanguage)
        }
        set {
            guard let newValue = newValue else {
                store.deleteObject(forKey: Constants.CacheKeys.prevAcceptedLanguage)
                return
            }
            store.setObject(newValue, forKey: Constants.CacheKeys.prevAcceptedLanguage)
        }
    }

    /// This language will be used instead of the phones' language when it is not `nil`. Remember
    /// to call `updateTranslations()` after changing the value.
    /// Otherwise, the effect will not be seen.
    public var languageOverride: Language? {
        get {
            return store.serializableForKey(Constants.CacheKeys.languageOverride)
        }

        set {
            if let newValue = newValue {
                store.setSerializable(newValue, forKey: Constants.CacheKeys.languageOverride)
            } else {
                store.deleteSerializableForKey(Constants.CacheKeys.languageOverride)
            }
            clearTranslations()
        }
    }

    // MARK: - Lifecycle -

    /// Instantiates and sets the type of the translations object and the repository from which
    /// translations are fetched. Usually this is invoked by the NStack start method, so under normal
    /// circumstances, it should not be neccessary to invoke it directly.
    ///
    /// - Parameters:
    ///   - translationsType: The type of the translations object that should be used.
    ///   - repository: Repository that can provide translations.
    internal init(translationsType: Translatable.Type,
                  repository: TranslationsRepository,
                  logger: LoggerType,
                  store: NOPersistentStore = Constants.persistentStore,
                  fileManager: FileManager = .default) {
        self.translationsType = translationsType
        self.repository = repository
        self.store = store
        self.fileManager = fileManager
        self.logger = logger
    }

    // MARK: - Update & Fetch -

    /// Fetches the latest version of the translations. Normally, the translations are aquired
    /// when performing the NStack public call, so in most scenarios, this method won't have to
    /// be called directly. Use it if you need to force refresh the translations during
    /// app use, for example if manually switching language.
    ///
    /// - Parameter completion: Called when translation fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    public func updateTranslations(_ completion: ((_ error: NStackError.Translations?) -> Void)? = nil) {
        repository.fetchTranslations(acceptLanguage: acceptLanguage) { response in
            switch response.result {
            case .success(let translationsData):

                var languageChanged = false
                if self.lastAcceptHeader != self.acceptLanguage {
                    self.clearTranslations(includingPersisted: true)
                    languageChanged = true
                }

                self.lastAcceptHeader = self.acceptLanguage
                self.set(translationsDictionary: translationsData.translations)

                completion?(nil)

                if languageChanged {
                    self.languageChangedAction?()
                }

            case .failure(let error):
                self.logger.log("Error downloading translations data.\nResponse: ",
                                response.response ?? "No response",
                                "\nData: ", response.data ?? "No data",
                                "\nError: ", error.localizedDescription, level: .error)
                completion?(.updateFailed(reason: error.localizedDescription))
            }
        }
    }

    /// Gets the languages for which translations are available.
    ///
    /// - Parameter completion: An Alamofire DataResponse object containing the array or languages on success.
    public func fetchAvailableLanguages(_ completion: @escaping (Alamofire.DataResponse<[Language]>) -> Void) {
        repository.fetchAvailableLanguages(completion: completion)
    }

    /// Gets the language which is currently used for translations, based on the accept header.
    ///
    /// - Parameter completion: An Alamofire DataResponse object containing the language on success.
    public func fetchCurrentLanguage(_ completion: @escaping (Alamofire.DataResponse<Language>) -> Void) {
        repository.fetchCurrentLanguage(acceptLanguage: acceptLanguage, completion: completion)
    }

    // MARK: - Accept Language -

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
            components.append(languageOverride.locale + ";q=1.0")
        }

        // Get all languages and calculate lowest quality
        var languages = repository.fetchPreferredLanguages()

        // Append fallback language if we don't have any provided
        if components.count == 0 && languages.count == 0 {
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

    // MARK: - Translations -

    /// The parsed translations object is cached in memory, but persisted as a dictionary. 
    /// If a persisted version cannot be found, the fallback json file in the bundle will be used.
    ///
    /// - Returns: A translations object.
    public func translations<T: Translatable>() -> T {
        // Clear translations if language changed
        if lastAcceptHeader != acceptLanguage {
            lastAcceptHeader = acceptLanguage
            clearTranslations()
        }

        // Check object in memory
        if let cachedObject = translationsObject as? T {
            return cachedObject
        }

        // Load persisted or fallback translations
        loadTranslations()

        // Now we must have correct translations, so return it
        return translationsObject as! T
    }

    /// Clears both the memory and persistent cache. Used for debugging purposes.
    ///
    /// - Parameter includingPersisted: If set to `true`, local persisted translation
    ///                                 file will be deleted.
    public func clearTranslations(includingPersisted: Bool = false) {
        translationsObject = nil

        if includingPersisted {
            persistedTranslations = nil
        }
    }

    /// Loads and initializes the translations object from either persisted or fallback dictionary.
    func loadTranslations() {
        let parsed = processAllTranslations(translationsDictionary)
        let translations = translationsType.init(dictionary: parsed)
        translationsObject = translations
    }

    // MARK: - Dictionaries -

    /// Saves the translations set.
    ///
    /// - Parameter translations: The new translations.
    func set(translationsDictionary: NSDictionary?) {
        // Persist the object
        persistedTranslations = translationsDictionary

        // Reload the translations
        _ = loadTranslations()
    }

    /// Returns the saved dictionary representation of the translations.
    var translationsDictionary: NSDictionary {
        return persistedTranslations ?? fallbackTranslations
    }

    /// Translations that were downloaded and persisted on disk.
    var persistedTranslations: NSDictionary? {
        get {
            return NSDictionary(contentsOf: translationsFileUrl)
        }
        set {
            // Delete if new value is nil
            guard let newValue = newValue else {
                do {
                    try fileManager.removeItem(at: translationsFileUrl)
                } catch {
                    logger.log("Failed to delete persisted translatons. \(error.localizedDescription)",
                        level: .error)
                }
                return
            }

            // Save to disk
            var url = translationsFileUrl
            guard newValue.write(to: url, atomically: true) else {
                logger.log("Failed to persist translations to disk.", level: .error)
                return
            }

            // Exclude from backup
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try url.setResourceValues(resourceValues)
            } catch {
                logger.log("Failed to exclude translations from backup. \(error.localizedDescription)",
                    level: .warning)
            }
        }
    }

    /// Loads the local JSON copy, has a return value so that it can be synchronously
    /// loaded the first time they're needed. The local JSON copy contains all available languages,
    /// and the right one is chosen based on the current locale.
    ///
    /// - Returns: A dictionary representation of the selected local translations set.
    var fallbackTranslations: NSDictionary {
        for bundle in Bundle.allBundles {
            guard let filePath = bundle.path(forResource: "Translations", ofType: "json") else {
                continue
            }

            let fileUrl = URL(fileURLWithPath: filePath)
            let data: Data

            do {
                data = try Data(contentsOf: fileUrl)
            } catch {
                logger.log("Failed to get data from fallback translations file. \(error.localizedDescription)",
                    level: .error)
                continue
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                guard let dictionary = json as? NSDictionary else {
                    logger.log("Failed to get NSDictionary from fallback JSON file.", level: .error)
                    continue
                }

                return dictionary
            } catch {
                logger.log("Error loading translations JSON file. \(error.localizedDescription)",
                    level: .error)
            }
        }

        logger.log("Failed to load fallback translations, file non-existent.", level: .error)
        return [:]
    }

    // MARK: - Parsing -

    /// Unwraps and extracts proper language dictionary out of the dictionary containing 
    /// all translations.
    ///
    /// - Parameter dictionary: Dictionary containing all translations under the `data` key.
    /// - Returns: Returns extracted language dictioanry for current accept language.
    private func processAllTranslations(_ dictionary: NSDictionary) -> NSDictionary? {
        guard let translations = dictionary.value(forKey: "data") as? NSDictionary else {
            logger.log("Failed to get data from all translations NSDictionary.", level: .error)
            return nil
        }

        return extractLanguageDictionary(fromDictionary: translations)
    }

    /// Uses the device's current locale to select the appropriate translations set.
    ///
    /// - Parameter json: A dictionary containing translation sets by language code key.
    /// - Returns: A translations set as a dictionary.
    func extractLanguageDictionary(fromDictionary dictionary: NSDictionary) -> NSDictionary {
        var languageDictionary: NSDictionary? = nil

        if let languageOverride = languageOverride {
            languageDictionary = translationsMatching(language: languageOverride,
                                                      inDictionary: dictionary)
        }

        if let languageDictionary = languageDictionary {
            return languageDictionary
        }

        let languages = repository.fetchPreferredLanguages()

        // First check to see if any of the translations match one of the user's device languages.
        for userLanguage in languages {
            languageDictionary = translationsMatching(locale: userLanguage, inDictionary: dictionary)
            if let languageDictionary = languageDictionary {
                return languageDictionary
            }
        }

        // No matches, see if something matches when only using first two characters.
        for userLanguage in languages {
            let index = userLanguage.characters.index(userLanguage.startIndex, offsetBy: 2)
            let substring = userLanguage.substring(to: index)
            languageDictionary = translationsMatching(locale: substring, inDictionary: dictionary)
            if let languageDictionary = languageDictionary {
                return languageDictionary
            }
        }

        // No matches, try English otherwise just use whatever the first one is
        languageDictionary = translationsMatching(locale: "en", inDictionary: dictionary) ??
            dictionary.allValues.first as? NSDictionary


        if let languageDictionary = languageDictionary {
            return languageDictionary
        }

        logger.log("Error loading translations. No translations available.", level: .error)
        return [:]
    }

    /// Searches the translation file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - language: The desired language. If `nil`, first language will be used.
    ///   - json: The dictionary containing translations for all languages.
    /// - Returns: Translations dictionary for the given language.
    func translationsMatching(language: Language, inDictionary dictionary: NSDictionary) -> NSDictionary? {
        return translationsMatching(locale: language.locale, inDictionary: dictionary)
    }

    /// Searches the translation file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - locale: A language code of the desired language.
    ///   - json: The dictionary containing translations for all languages.
    /// - Returns: Translations dictionary for the given language.
    func translationsMatching(locale: String, inDictionary dictionary: NSDictionary) -> NSDictionary? {
        for case let key as String in dictionary.allKeys {
            if key == locale {
                return dictionary.value(forKey: key) as? NSDictionary
            }
        }
        
        return nil
    }
    
    // MARK: - Helpers -

    /// The URL used to persist downloaded translations.
    var translationsFileUrl: URL {
        return fileManager.documentsDirectory.appendingPathComponent("Translations.nstack")
    }
}
