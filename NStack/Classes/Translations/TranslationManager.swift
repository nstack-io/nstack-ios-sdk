//
//  TranslationsManager.swift
//  NStack
//
//  Created by Chris Combs on 08/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable
import Harbor
import Cashier

/**

The Translations Manager handles everything related to translations.

Usually, direct interaction with the Translations Manager shouldn't be neccessary, since it is setup automatically by the NStack manager, and the translations are accssible by the globael 'tr()' function defined in the auto-generated translations swift file.

*/

public struct TranslationManager {
    
    static let allTranslationsUserDefaultsKey = "NSTACK_ALL_TRANSLATIONS_USER_DEFAULTS_KEY"
    
    let translationType:Translatable.Type
    
    public static var sharedInstance:TranslationManager!
    
    var cachedTranslationsObject:Translatable?
    
    public var lastFetchedLanguage:Language?
    
    init(type:Translatable.Type) {
        self.translationType = type
    }
    
    /**
    
    Instantiates the shared singleton instance and sets the type of the translations object. Usually this is invoked by the NStack start method, so under normal circumstances, it should not be neccessary to invoke it directly.
    
    - parameter translationsType: The type of the translations object that should be used.
    
    */
    
    public static func start(translationsType translationsType:Translatable.Type) {
        sharedInstance = TranslationManager(type:translationsType)
    }
    
    //MARK: - Public update call
    
    /**
    
    Fetches the latest version of the translations. Normally, the translations are aquired when performing the NStack Open call,
    so in most scenarios, this method won't have to be called directly. Use it if you need to force refresh the translations during
    app use, for example if manually switching language.
    
    - parameter completion: (Optional) Called when translation fetching has finished. Check if the error object is nil to determine whether the operation was a succes.
    
    */
    
    public mutating func updateTranslations(completion:((error:NSError?) -> Void)? = nil) {
        
        NStackConnectionManager.fetchTranslations { (result) -> Void in
            
            switch result {
            case .Success(let JSONdata):
                
                if let JSONdata = JSONdata {
                    let unwrapped = JSONdata["data"] as? [String : AnyObject]
                    let meta = JSONdata["meta"] as? [String : AnyObject]
                    let language = meta?["language"] as? [String : AnyObject]
                    
                    let translations = self.translationType.init(dictionary: unwrapped)
                    self.setTranslations(translations)
                    
                    let lang = Language.init(dictionary: language)
                    TranslationManager.sharedInstance.lastFetchedLanguage = lang
                    completion?(error: nil)
                } else {
                    completion?(error: NSError(domain: "NStack", code: 100, userInfo: [ NSLocalizedDescriptionKey : "Translations response empty"]))
                }
                
            case .Error(let response, let error, let rawResponse):
                print("Error downloading Translations data")
                print(response, rawResponse)
                if let error = error {
                    print(error)
                }
                completion?(error: error)
                return
            }
        }
    }
    
    public mutating func fetchCurrentLanguage(completion:((error:NSError?) -> Void)? = nil) {
        
        NStackConnectionManager.fetchCurrentLanguage({ (result) -> Void in
            switch result {
            case .Success(let language):
                
                TranslationManager.sharedInstance.lastFetchedLanguage = language
                completion?(error: nil)
                
            case .Error(let response, let error, let rawResponse):
                print("Error downloading Language data")
                print(response, rawResponse)
                if let error = error {
                    print(error)
                }
                completion?(error: error)
                return
            }
        })
    }
    
    /**
    
    Clears both the memory and persistent cache. Used for debugging purposes.
    
    */
    
    public mutating func clearSavedTranslations() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TranslationManager.allTranslationsUserDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        cachedTranslationsObject = nil
    }
    
    /**
    
    The parsed translations object is cached in memory, but persisted as a dictionary. If a persisted version cannot be found,
    the fallback json file in the bundle will be used.
    
    - returns: A translations object
    
    */
    
    public mutating func translations<T:Translatable>() -> T {
        
        if let lastRequestedAcceptLangString:String? = NOPersistentStore.cacheWithId( NStackConstants.persistentStoreID).objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String where lastRequestedAcceptLangString != acceptLanguageHeaderValueString() {
            clearSavedTranslations()
        }
        
        if let cachedObject = cachedTranslationsObject as? T {
            return cachedObject
        }
        
        let savedTransDict = savedTranslationsDict()
        let fallback = T(dictionary: savedTransDict)
        cachedTranslationsObject = fallback
        return fallback
    }
    
    /**
    
    Saves the translations set.
    
    - parameter translations: The new translations
    
    */
    
    mutating func setTranslations(translations:Translatable) {
        self.setTranslationsSource(translations.encodableRepresentation())
    }
    
    /**
    
    Returns the saved dictionary representation of the translations
    
    - parameter translations: A dictionary representation of the translations
    
    */
    
    public func savedTranslationsDict() -> [String : AnyObject] {
        if let savedTranslationsDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(TranslationManager.allTranslationsUserDefaultsKey) {
            return savedTranslationsDict
        }
        
        return loadTranslationFromLocalFile()
    }
    
    /**
    
    Directly saves the persisted dictionary representation of the translations
    
    - parameter sourceDict: A dictionary representation of the translations
    
    */
    
    mutating func setTranslationsSource(sourceDict:NSCoding) {
        
        NSUserDefaults.standardUserDefaults().setObject(sourceDict, forKey: TranslationManager.allTranslationsUserDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        cachedTranslationsObject = nil
    }
    
    //MARK: - Public Language Methods
    
    /**
    
    Gets the languages for which translations are available
    
    */
    
    public func fetchAvailableLanguages(completion:(ApiResult<[Language]>) -> Void) {
        
        NStackConnectionManager.fetchAvailableLanguages(completion)
    }
    
    /**
    
    This language will be used instead of the phones' language when it is not *nil*
    Remember to call *updateTranslations* after changing the value. Otherwise, the effect might not be seen.
    
    */
    
    public var languageOverride:Language? { didSet { clearSavedTranslations() } }
    
    public func acceptLanguageHeaderValueString() -> String {
        
        var components: [String] = []
        
        if let languageOverride = languageOverride {
            components.append(languageOverride.locale)
        }
        
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
        
        //TODO: find a way to check region as well as language? In case we get to a point
        // with our translations where that will make a difference (en-US vs en-UK for example)
        
        if let languageOverride = languageOverride {
            languageJSON = findTranslationMatchingLanguage(languageOverride.locale, inJSON: json)
        }
        
        if languageJSON == nil {
            // First check to see if any of the translations match one of the user's device languages
            for userLanguage in NSLocale.preferredLanguages() {
                if languageJSON != nil {
                    // Already found one
                    break
                }
                else {
                    var string = userLanguage as NSString
                    if string.length > 2 { // iOS9 changed it from "en" to "en-US" (as an example)
                        string = string.substringToIndex(2)
                    }
                    languageJSON = findTranslationMatchingLanguage(string as String, inJSON: json)
                }
            }
            
            if languageJSON == nil {
                // No matches, try English
                languageJSON = findTranslationMatchingLanguage("en", inJSON: json)
            }
            if languageJSON == nil {
                // No English translation, just use whatever the first one is
                languageJSON = findTranslationMatchingLanguage(nil, inJSON: json)
            }
        }
        
        guard let lang = languageJSON else {
            // There are no translations?
            print("Error loading translations. No translations available")
            return [String : AnyObject]()
        }
        
        return lang
    }
    
    // Searches the translation file for a key matching the provided language code
    public func findTranslationMatchingLanguage(language: String?, inJSON json: [String : AnyObject]) -> [String : AnyObject]? {
        if let language = language  {
            for key in (json as NSDictionary).allKeys {
                if (key as! NSString).substringToIndex(2) == (language as NSString).substringToIndex(2) {
                    return json[key as! String] as? [String : AnyObject]
                }
            }
        }
            // Intentionally passed nil to get the first language in the file
        else {
            if let keys = (json as NSDictionary).allKeys as? [String] {
                return json[keys[0]] as? [String : AnyObject]
            }
        }
        return nil
        
    }
}
