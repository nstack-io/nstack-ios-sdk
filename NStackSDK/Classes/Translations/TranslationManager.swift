//
//  TranslationsManager.swift
//  NStack
//
//  Created by Chris Combs on 08/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable
import Cashier
import Alamofire

/**
 The Translations Manager handles everything related to translations.

 Usually, direct interaction with the `Translations Manager` shouldn't be neccessary, since it is
 setup automatically by the NStack manager, and the translations are accessible by the global 'tr()'
 function defined in the auto-generated translations Swift file.
*/
public class TranslationManager {
    
    public static let sharedInstance = TranslationManager()
    public var lastFetchedLanguage: Language?

    let allTranslationsUserDefaultsKey = "NSTACK_ALL_TRANSLATIONS_USER_DEFAULTS_KEY"

    var translationType: Translatable.Type!
    var cachedTranslationsObject: Translatable?

    internal private(set) var configured = false
    private init() {}

    /**
     Instantiates the shared singleton instance and sets the type of the translations object. Usually this is invoked by the NStack start method, so under normal circumstances, it should not be neccessary to invoke it directly.
    
    - parameter translationsType: The type of the translations object that should be used.
    */
    public static func start(translationsType type: Translatable.Type) {
        sharedInstance.translationType = type
        sharedInstance.configured = true
    }
    
    //MARK: - Public update call
    
    /**
    
    Fetches the latest version of the translations. Normally, the translations are aquired when performing the NStack Open call,
    so in most scenarios, this method won't have to be called directly. Use it if you need to force refresh the translations during
    app use, for example if manually switching language.
    
    - parameter completion: (Optional) Called when translation fetching has finished. Check if the error object is nil to determine whether the operation was a succes.
    
    */
    
    public func updateTranslations(completion: ((error: NStackError.Translations?) -> Void)? = nil) {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            completion?(error: .NotConfigured)
            return
        }

        ConnectionManager.fetchTranslations { (response) -> Void in
            
            switch response.result {
            case .Success(let translationsData):
                let translations = self.translationType.init(dictionary: translationsData.translations)
                self.setTranslations(translations)

                if let language = translationsData.languageData?.language {
                    TranslationManager.sharedInstance.lastFetchedLanguage = language
                }

                completion?(error: nil)

            case .Failure(let error):
                self.print("Error downloading translations data.")
                self.print(response.response, response.data)
                self.print(error.localizedDescription)
                completion?(error: .UpdateFailed(reason: error.localizedDescription))
                return
            }
        }
    }
    
    public func fetchCurrentLanguage(completion: ((error:NSError?) -> Void)? = nil) {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return
        }

        ConnectionManager.fetchCurrentLanguage({ (response) -> Void in
            switch response.result {
            case .Success(let language):
                TranslationManager.sharedInstance.lastFetchedLanguage = language
                completion?(error: nil)
                
            case .Failure(let error):
                self.print("Error downloading language data: ", error.localizedDescription)
                self.print("Response: ", response.response)
                self.print("Data: ", response.data)

                completion?(error: error)

                return
            }
        })
    }
    
    /**
    
    Clears both the memory and persistent cache. Used for debugging purposes.
    
    */
    
    public func clearSavedTranslations() {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return
        }

        NSUserDefaults.standardUserDefaults().removeObjectForKey(allTranslationsUserDefaultsKey)
        cachedTranslationsObject = nil
    }
    
    /**
    
    The parsed translations object is cached in memory, but persisted as a dictionary. If a persisted version cannot be found,
    the fallback json file in the bundle will be used.
    
    - returns: A translations object
    
    */
    
    public func translations<T:Translatable>() -> T {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return T(dictionary: nil)
        }

        if let lastRequestedAcceptLangString:String? = NStack.persistentStore.objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String
            where lastRequestedAcceptLangString != acceptLanguageHeaderValueString() {
            clearSavedTranslations()
        }
        
        if let cachedObject = cachedTranslationsObject as? T {
            return cachedObject
        }
        
        let fallback = T(dictionary: savedTranslationsDict())
        cachedTranslationsObject = fallback
        return fallback
    }
    
    /**
    
    Saves the translations set.
    
    - parameter translations: The new translations
    
    */
    
    private func setTranslations(translations: Translatable) {
        setTranslationsSource(translations.encodableRepresentation())
    }
    
    /**
    
    Returns the saved dictionary representation of the translations
    
    - parameter translations: A dictionary representation of the translations
    
    */
    
    public func savedTranslationsDict() -> [String : AnyObject] {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return [:]
        }

        if let savedTranslationsDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(allTranslationsUserDefaultsKey) {
            return savedTranslationsDict
        }

        return loadTranslationFromLocalFile()
    }
    
    /**
     Directly saves the persisted dictionary representation of the translations

     - parameter sourceDict: A dictionary representation of the translations
     */
    func setTranslationsSource(sourceDict: NSCoding) {
        NSUserDefaults.standardUserDefaults().setObject(sourceDict, forKey: allTranslationsUserDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        cachedTranslationsObject = nil
    }
    
    // MARK: - Public Language Methods -

    /**
     Gets the languages for which translations are available

     - parameter completion: An Alamofire Response object containing the array or languages on success
     */
    
    public func fetchAvailableLanguages(completion: Alamofire.Response<[Language], NSError> -> Void) {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return
        }

        ConnectionManager.fetchAvailableLanguages(completion)
    }
    
    /// This language will be used instead of the phones' language when it is not *nil*
    /// Remember to call *updateTranslations* after changing the value. Otherwise, the effect might not be seen.
    public var languageOverride: Language? {
        set {
            
            if let newValue = newValue {
                NStack.persistentStore.setSerializable(newValue, forKey: "LANGUAGE_OVERIDE")
            } else {
                NStack.persistentStore.deleteSerializableForKey("LANGUAGE_OVERIDE")
            }
            clearSavedTranslations()
        }
        get {
            return NStack.persistentStore.serializableForKey("LANGUAGE_OVERIDE")
        }
    }

    /**
     Returns a string containing the current locale's preferred languages in a prioritized manner to be used in a accept-language header.
     Format example:
     
     "da;q=1.0, en-gb;q=0.8, en;q=0.7"

     - returns: A string
     */
    public func acceptLanguageHeaderValueString() -> String {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return ""
        }

        var components: [String] = []
        
        if let languageOverride = languageOverride {
            components.append(languageOverride.locale)
        }

        // FIXME: Black magic, needs comments
        for (index, languageCode) in (NSLocale.preferredLanguages() as [String]).enumerate() {
            let q = 1.0 - (Double(index) * 0.1)
            components.append("\(languageCode);q=\(q)")
            if q <= 0.5 {
                break
            }
        }
        
        return components.joinWithSeparator(",")
    }
    
    //MARK: - Private instance methods
    
    /**
     Loads the local JSON copy, has a return value so that it can be synchronously loaded the first time they're needed.
     the local JSON copy contains all available languages, and the right one is chosen based on the current locale.
    
    - returns: A dictionary representation of the selected local translations set.
    */
    private func loadTranslationFromLocalFile() -> [String : AnyObject] {
        for bundle in NSBundle.allBundles() {
            if let filePath = bundle.pathForResource("Translations", ofType: "json"), data = NSData(contentsOfFile: filePath) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject] {
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
    
    /**
     Uses the device's current locale to select the appropriate translations set.
    
    - parameter json: A dictionary containing translation sets by language code key.

    - returns: A translations set as a dictionary.
    */
    private func parseTranslationsFromJSON(json: [String : AnyObject]) -> [String : AnyObject] {
        var languageJSON: [String : AnyObject]? = nil
        
        if let languageOverride = languageOverride {
            languageJSON = findTranslationMatchingLanguage(languageOverride.locale, inJSON: json)
        }
        
        if languageJSON == nil {
            // First check to see if any of the translations match one of the user's device languages
            for userLanguage in NSLocale.preferredLanguages() {
                languageJSON = findTranslationMatchingLanguage(userLanguage, inJSON: json)
                if languageJSON != nil { break }
            }
            
            //No matches, see if something matches when only using first two characters
            for userLanguage in NSLocale.preferredLanguages() {
                languageJSON = findTranslationMatchingLanguage(userLanguage.substringToIndex(userLanguage.startIndex.advancedBy(2)), inJSON: json)
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

    /**
     Searches the translation file for a key matching the provided language code.

     - parameter language: A language code of the desired language. If `nil`, first language will be used.
     - parameter json:     The JSON file containing translations for all languages.

     - returns: Translations dictionary for the given language.
     */
    public func findTranslationMatchingLanguage(language: String, inJSON json: [String : AnyObject]) -> [String : AnyObject]? {
        guard configured else {
            print(NStackError.Translations.NotConfigured.description)
            return nil
        }

        for (key, _) in json {
            if key == language {
                if language.characters.count < key.characters.count { /* iOS 8 returns two-char language without the region */
                    return json[key.substringToIndex(key.startIndex.advancedBy(language.characters.count))] as? [String : AnyObject]
                }
                return json[key] as? [String : AnyObject]
            }
        }

        return nil
    }

    // MARK: - Helpers -

    internal func print(items: Any...) {
        NStack.sharedInstance.print(items)
    }
}
