//
//  NStack.swift
//  NStack
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

public struct Configuration {
    
    public let appId:String
    public let restAPIKey:String
    public let translationsClass:Translatable.Type?
    public var updateAutomaticallyOnStart = true
    public var updatesOnApplicationDidBecomeActive = true
    public var verboseMode = false
    public var flat = false

    private static let UUIDKey = "NSTACK_UUID_DEFAULTS_KEY"
    
    internal static func guid() -> String {
        let savedUUID = UserDefaults.standard().object(forKey: UUIDKey)
        if let UUID = savedUUID as? String {
            return UUID
        }

        let newUUID = UUID().uuidString
        UserDefaults.standard().set(newUUID, forKey: UUIDKey)
        UserDefaults.standard().synchronize()
        return newUUID
    }
    
    public init(appId:String, restAPIKey:String, translationsClass:Translatable.Type? = nil) {
        self.appId = appId
        self.restAPIKey = restAPIKey
        self.translationsClass = translationsClass
    }
    
    public init(plistName:String, translationsClass:Translatable.Type? = nil) {
        
        var appId:String?
        var restAPIKey:String?
        var flatString:String?

        for bundle in Bundle.allBundles() {
            let fileName = plistName.replacingOccurrences(of: ".plist", with: "")
            if let fileURL = bundle.urlForResource(fileName, withExtension: "plist") {

                let object = NSDictionary(contentsOf: fileURL)

                guard let keyDict = object as? [String : AnyObject] else {
                    fatalError("Can't parse file \(fileName).plist")
                }
                
                appId = keyDict["APPLICATION_ID"] as? String
                restAPIKey = keyDict["REST_API_KEY"] as? String
                flatString = keyDict["FLAT"] as? String
                break
            }
        }
        
        guard let finalAppId = appId else { fatalError("Couldn't initialize appId") }
        
        guard let finalRestAPIKey = restAPIKey else { fatalError("Couldn't initialize REST API key") }
        
        self.appId = finalAppId
        self.restAPIKey = finalRestAPIKey
        self.translationsClass = translationsClass
        if let flat = flatString {
            if flat == "1" {
                self.flat = true
            }
        }
    }
}

public struct NStack {
    
    
    internal let observer:ApplicationObserver?
    
    //MARK: - Variables
    
    public static var sharedInstance:NStack!
    
    /**
     
    The configuration object the shared instance have been initialized with.
     
     */
    
    public let configuration:Configuration
    
    /**
    
    This gets called when the phone language has changed while app is running. At this point, translations have been updated, if there was an internet connection.
    
    */
    
    public var languageChangedHandler:(() -> Void)?
    
    private var avoidUpdateList = [UIApplicationLaunchOptionsLocationKey]
    
    //MARK: - Start NStack
    
    /**
    
    Initializes NStack and, if *updateAutomaticallyOnStart* is set on the passed *configuration* object, fetches all data (including translations if a translations type is set in the configuration object) from NStack API right away.
    
    - parameter configuration: A *configuration* object containing API keys and translations type
    
    */
    public static func start(configuration: Configuration, launchOptions: [NSObject: AnyObject]?) {
        sharedInstance = NStack(configuration: configuration)
        
        var shouldUpdate = true
        if let launchOptions = launchOptions {
            for key in sharedInstance.avoidUpdateList {
                if launchOptions[key] != nil {
                    shouldUpdate = false
                }
            }
        }
        if let translationsClass = configuration.translationsClass {
            TranslationManager.start(translationsType: translationsClass)
            if shouldUpdate {
                if NStackVersionUtils.isVersion(NStackVersionUtils.currentAppVersion(), greaterThanVersion: NStackVersionUtils.previousAppVersion()) {
                    TranslationManager.sharedInstance.clearSavedTranslations()
                }
                if configuration.updateAutomaticallyOnStart {
                    sharedInstance.update()
                }
            }
            else {
                let _ = TranslationManager.sharedInstance
            }
        }
    }
    
    //MARK: - Synchronize
    
    /**
    
    Fetches the latest data from the NStack server and updates accordingly.
    
    - Shows appropriate notifications to the user (Update notifications, what's new, messages, rate reminders).
    - Updates the translation strings for current language.
    
    *Note:* By default, this is automatically invoked after *NStack.start()* has been called and subsequently on applicationDidBecomeActive.
    To override this behavior, see the properties on the *configuration* struct.
    
    - parameter completion: This is run after the call has finished. If *error* was nil, translation strings are up-to-date
    
    */
    public func update(_ completion: ((error:NSError?)->Void)? = nil ) {
        NStackConnectionManager.doAppOpenCall(oldVersion: NStackVersionUtils.previousAppVersion(), currentVersion: NStackVersionUtils.currentAppVersion()) { response in
            switch response.result {
            case .success(let JSONdata):
                guard let dictionary = JSONdata as? NSDictionary else {
                    if NStack.sharedInstance.configuration.verboseMode {
                        print("failure: couldn't parse response")
                    }
                    completion?(error: NSError(domain: "com.nodes.nstack", code: 1000, userInfo: [NSLocalizedDescriptionKey : "Couldn't parse response dictionary."]))
                    return
                }

                let wrapper = AppOpenResponseWrapper(dictionary: dictionary)
                
                if NStack.sharedInstance.configuration.verboseMode {
                    print(wrapper)
                }
                
                if let appOpenResponseData = wrapper.data{
                    
                    if appOpenResponseData.translate.count > 0 {
                        if var manager = TranslationManager.sharedInstance {
                            manager.setTranslationsSource(appOpenResponseData.translate)
                        }
                    }
                    
                    if !AlertManager.sharedInstance.alreadyShowingAlert {
                        
                        if let newVersion = appOpenResponseData.update?.newerVersion {
                            AlertManager.sharedInstance.showUpdateAlert(newVersion: newVersion)
                            
                        } else if let changelog = appOpenResponseData.update?.newInThisVersion {
                            AlertManager.sharedInstance.showWhatsNewAlert(changelog)
                            
                        } else if let message = appOpenResponseData.message {
                            AlertManager.sharedInstance.showMessage(message)
                            
                        } else if let rateReminder = appOpenResponseData.rateReminder {
                            AlertManager.sharedInstance.showRateReminder(rateReminder)
                        }
                        
                        NStackVersionUtils.setPreviousAppVersion(NStackVersionUtils.currentAppVersion())
                    }
                    
                    
                    if let languageMetaData = wrapper.meta{
                        
                        let lang = languageMetaData.language
                        TranslationManager.sharedInstance.lastFetchedLanguage = lang
                    }
                    
                    NStackConnectionManager.setLastUpdatedToNow()
                }
                
                completion?(error: nil)

            case let .failure(error):
                if NStack.sharedInstance.configuration.verboseMode {
                    print("failure: \(response.response ?? "unknown error")")
                }
                completion?(error: error)
            }
        }
    }
    
    private init(configuration: Configuration) {
        self.configuration = configuration
        if configuration.updatesOnApplicationDidBecomeActive {
            observer = ApplicationObserver()
        } else {
            observer = nil
        }
    }
}

//MARK: - Geography
public extension NStack {
	
	/**
	Updates the list of countries stored by NStack
		
	- parameter completion: Optional completion block when the API call has finished.
	*/
	public static func updateCountries(completion: ((countries: [Country], error: NSError?) -> ())? = nil) {
		NStackConnectionManager.fetchCountries { (response) in
			switch response.result {
			case .Success(let data):
				countries = data
				completion?(countries: data, error: nil)
			case .Failure(let error):
				completion?(countries: [], error: error)
			}
		}
	}
	
	/// Locally stored list of countries
	public static private(set) var countries: [Country]? {
		get {
			return NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).serializableForKey(NStackConstants.CountriesKey)
		}
		set {
			if let newValue = newValue {
				NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).setSerializable(newValue, forKey: NStackConstants.CountriesKey)
			}
			else {
				NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).deleteSerializableForKey(NStackConstants.CountriesKey)
			}
		}
	}
}
