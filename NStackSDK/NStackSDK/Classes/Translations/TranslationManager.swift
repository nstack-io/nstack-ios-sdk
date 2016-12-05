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
/// Usually, direct interaction with the `Translations Manager` shouldn't be neccessary, since it is
/// setup automatically by the NStack manager, and the translations are accessible by the global 'tr'
/// variable defined in the auto-generated translations Swift file.
public class TranslationManager {

    public var lastFetchedLanguage: Language?

    let allTranslationsUserDefaultsKey = "NSTACK_ALL_TRANSLATIONS_USER_DEFAULTS_KEY"

    let repository: TranslationsRepository
    let translationsType: Translatable.Type

    var cachedTranslationsObject: Translatable?

    /// This language will be used instead of the phones' language when it is not *nil*
    /// Remember to call *updateTranslations* after changing the value. Otherwise, the effect might not be seen.
    public var languageOverride: Language? {
        get {
            return NStack.sharedInstance.persistentStore.serializableForKey("LANGUAGE_OVERIDE")
        }

        set {
            if let newValue = newValue {
                NStack.sharedInstance.persistentStore.setSerializable(newValue, forKey: "LANGUAGE_OVERIDE")
            } else {
                NStack.sharedInstance.persistentStore.deleteSerializableForKey("LANGUAGE_OVERIDE")
            }
            clearSavedTranslations()
        }
    }


    /// Instantiates and sets the type of the translations object and the repository from which
    /// translations are fetched. Usually this is invoked by the NStack start method, so under normal
    /// circumstances, it should not be neccessary to invoke it directly.
    ///
    /// - Parameters:
    ///   - translationsType: The type of the translations object that should be used.
    ///   - repository: Repository that can provide translations.
    internal init(translationsType: Translatable.Type, repository: TranslationsRepository) {
        self.translationsType = translationsType
        self.repository = repository
    }

    /// Fetches the latest version of the translations. Normally, the translations are aquired 
    /// when performing the NStack public call, so in most scenarios, this method won't have to 
    /// be called directly. Use it if you need to force refresh the translations during
    /// app use, for example if manually switching language.
    ///
    /// - Parameter completion: Called when translation fetching has finished. Check if the error
    ///                         object is nil to determine whether the operation was a succes.
    public func updateTranslations(_ completion: ((_ error: NStackError.Translations?) -> Void)? = nil) {

        repository.fetchTranslations(acceptLanguage: TranslationManager.acceptLanguageHeaderValueString(languageOverride: languageOverride)) { (response) -> Void in
            
            switch response.result {
            case .success(let translationsData):
                let translations = self.translationsType.init(dictionary: translationsData.translations as NSDictionary?)
                self.setTranslations(translations)

                if let language = translationsData.languageData?.language {
                    self.lastFetchedLanguage = language
                }

                completion?(nil)

            case .failure(let error):
                self.print("Error downloading translations data.")
                self.print(response.response ?? "No response", response.data ?? "No data")
                self.print(error.localizedDescription)
                completion?(.updateFailed(reason: error.localizedDescription))
                return
            }
        }
    }

    /// <#Description#>
    ///
    /// - Parameter completion: <#completion description#>
    public func fetchCurrentLanguage(_ completion: ((_ error:Error?) -> Void)? = nil) {
        repository.fetchCurrentLanguage(completion: { (response) -> Void in
            switch response.result {
            case .success(let language):
                self.lastFetchedLanguage = language
                completion?(nil)
                
            case .failure(let error):
                self.print("Error downloading language data: ", error.localizedDescription)
                self.print(response.response ?? "No response", response.data ?? "No data")

                completion?(error)

                return
            }
        })
    }

    /// Clears both the memory and persistent cache. Used for debugging purposes.
    public func clearSavedTranslations() {
        UserDefaults.standard.removeObject(forKey: allTranslationsUserDefaultsKey)
        cachedTranslationsObject = nil
    }

    /// The parsed translations object is cached in memory, but persisted as a dictionary. If a persisted version cannot be found,
    /// the fallback json file in the bundle will be used.
    ///
    /// - Returns: A translations object.
    public func translations<T:Translatable>() -> T {
        if let lastRequestedAcceptLangString:String = NStack.sharedInstance.persistentStore.object(forKey: NStackConstants.prevAcceptedLanguageKey) as? String,
            lastRequestedAcceptLangString != TranslationManager.acceptLanguageHeaderValueString(languageOverride: languageOverride) {
            clearSavedTranslations()
        }
        
        if let cachedObject = cachedTranslationsObject as? T {
            return cachedObject
        }
        
        let fallback = T(dictionary: savedTranslationsDict() as NSDictionary?)
        cachedTranslationsObject = fallback
        return fallback
    }

    /// Saves the translations set.
    ///
    /// - Parameter translations: The new translations.
    fileprivate func setTranslations(_ translations: Translatable) {
        setTranslationsSource(translations.encodableRepresentation())
    }
    
    /// Returns the saved dictionary representation of the translations.
    ///
    /// - Returns: A dictionary representation of the translations.
    public func savedTranslationsDict() -> [String : AnyObject] {
        if let savedTranslationsDict = UserDefaults.standard.dictionary(forKey: allTranslationsUserDefaultsKey) {
            return savedTranslationsDict as [String : AnyObject]
        }

        return loadTranslationFromLocalFile()
    }

    /// Directly saves the persisted dictionary representation of the translations
    ///
    /// - Parameter sourceDict: A dictionary representation of the translations.
    func setTranslationsSource(_ sourceDict: NSCoding) {
        UserDefaults.standard.set(sourceDict, forKey: allTranslationsUserDefaultsKey)
        UserDefaults.standard.synchronize()
        cachedTranslationsObject = nil
    }
    
    // MARK: - Public Language Methods -

    /// Gets the languages for which translations are available.
    ///
    /// - Parameter completion: An Alamofire Response object containing the array or languages on success.
    public func fetchAvailableLanguages(_ completion: @escaping (Alamofire.DataResponse<[Language]>) -> Void) {
        repository.fetchAvailableLanguages(completion: completion)
    }

    /// Returns a string containing the current locale's preferred languages in a prioritized manner to be used in a accept-language header.
    /// Format example:
    ///
    /// "da;q=1.0, en-gb;q=0.8, en;q=0.7"
    ///
    /// - Parameter languageOverride: <#languageOverride description#>
    /// - Returns: A string.
    public static func acceptLanguageHeaderValueString(languageOverride: Language? = nil) -> String {
        var components: [String] = []
        
        if let languageOverride = languageOverride {
            components.append(languageOverride.locale)
        }

        // FIXME: Black magic, needs comments
        for (index, languageCode) in (Locale.preferredLanguages as [String]).enumerated() {
            let q = 1.0 - (Double(index) * 0.1)
            components.append("\(languageCode);q=\(q)")
            if q <= 0.5 {
                break
            }
        }
        
        return components.joined(separator: ",")
    }
    
    //MARK: - Private instance methods
    
    /// Loads the local JSON copy, has a return value so that it can be synchronously
    /// loaded the first time they're needed. The local JSON copy contains all available languages, 
    /// and the right one is chosen based on the current locale.
    ///
    /// - Returns: A dictionary representation of the selected local translations set.
    fileprivate func loadTranslationFromLocalFile() -> [String : AnyObject] {
        for bundle in Bundle.allBundles {
            if let filePath = bundle.path(forResource: "Translations", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                        let unwrapped = json["data"] as? [String : AnyObject]
                        
                        if let data = unwrapped {
                            return parseTranslationsFromJSON(data)
                        } else {
                            return [String: AnyObject]()
                        }
                    }
                }
                catch {
                    //TODO: error handling
                    print("Error loading translations JSON file")
                    print(error)
                    
                }
            }
        }
        return [String : AnyObject]()
    }

    /// Uses the device's current locale to select the appropriate translations set.
    ///
    /// - Parameter json: A dictionary containing translation sets by language code key.
    /// - Returns: A translations set as a dictionary.
    fileprivate func parseTranslationsFromJSON(_ json: [String : AnyObject]) -> [String : AnyObject] {
        var languageJSON: [String : AnyObject]? = nil
        
        if let languageOverride = languageOverride {
            languageJSON = findTranslationMatchingLanguage(languageOverride.locale, inJSON: json)
        }
        
        if languageJSON == nil {
            // First check to see if any of the translations match one of the user's device languages
            for userLanguage in Locale.preferredLanguages {
                languageJSON = findTranslationMatchingLanguage(userLanguage, inJSON: json)
                if languageJSON != nil { break }
            }
            
            //No matches, see if something matches when only using first two characters
            for userLanguage in Locale.preferredLanguages {
                languageJSON = findTranslationMatchingLanguage(userLanguage.substring(to: userLanguage.characters.index(userLanguage.startIndex, offsetBy: 2)), inJSON: json)
                if languageJSON != nil { break }
            }
            
            if languageJSON == nil {
                // No matches, try English
                languageJSON = findTranslationMatchingLanguage("en", inJSON: json)
            }
            if languageJSON == nil {
                // No English translation, just use whatever the first one is
                languageJSON = json.values.first as? [String : AnyObject]
            }
        }
        
        guard let lang = languageJSON else {
            // There are no translations?
            print("Error loading translations. No translations available")
            return [String : AnyObject]()
        }
        
        return lang
    }

    /// Searches the translation file for a key matching the provided language code.
    ///
    /// - Parameters:
    ///   - language: A language code of the desired language. If `nil`, first language will be used.
    ///   - json: The JSON file containing translations for all languages.
    /// - Returns: Translations dictionary for the given language.
    public func findTranslationMatchingLanguage(_ language: String, inJSON json: [String : AnyObject]) -> [String : AnyObject]? {
        for (key, _) in json {
            if key == language {
                if language.characters.count < key.characters.count { /* iOS 8 returns two-char language without the region */
                    return json[key.substring(to: key.characters.index(key.startIndex, offsetBy: language.characters.count))] as? [String : AnyObject]
                }
                return json[key] as? [String : AnyObject]
            }
        }

        return nil
    }

    // MARK: - Helpers -

    internal func print(_ items: Any...) {
        NStack.sharedInstance.print(items)
    }
}
