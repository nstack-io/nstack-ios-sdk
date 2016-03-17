//
//  NStack.swift
//  NStack
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Harbor

public struct Configuration {
    
    public let appId:String
    public let restAPIKey:String
    public let translationsClass:Translatable.Type?
    public var updateAutomaticallyOnStart = true
    public var updatesOnApplicationDidBecomeActive = true
    public var verboseMode = false
    public var flat = false {
        didSet {
            print("flat: \(flat)")
        }
    }
    
    private static let UUIDKey = "NSTACK_UUID_DEFAULTS_KEY"
    
    internal static func guid() -> String {
        let savedUUID = NSUserDefaults.standardUserDefaults().objectForKey(UUIDKey)
        if let UUID = savedUUID as? String {
            return UUID
        }
        
        let newUUID = NSUUID().UUIDString
        NSUserDefaults.standardUserDefaults().setObject(newUUID, forKey: UUIDKey)
        NSUserDefaults.standardUserDefaults().synchronize()
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
        
        for bundle in NSBundle.allBundles() {
            let fileName = plistName.stringByReplacingOccurrencesOfString(".plist", withString: "")
            if let fileURL = bundle.URLForResource(fileName, withExtension: "plist") {

                let object = NSDictionary(contentsOfURL: fileURL)

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
    
    
    //MARK: - Start NStack
    
    /**
    
    Initializes NStack and, if *updateAutomaticallyOnStart* is set on the passed *configuration* object, fetches all data (including translations if a translations type is set in the configuration object) from NStack API right away.
    
    - parameter configuration: A *configuration* object containing API keys and translations type
    
    */
    
    public static func start(configuration configuration: Configuration) {
        sharedInstance = NStack(configuration: configuration)
        if let translationsClass = configuration.translationsClass {
            TranslationManager.start(translationsType: translationsClass)
            if configuration.updateAutomaticallyOnStart {
                sharedInstance.update()
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
    
    public func update(completion: ((error:NSError?)->Void)? = nil ) {
        NStackConnectionManager.doAppOpenCall(oldVersion: NStackVersionUtils.previousAppVersion(), currentVersion: NStackVersionUtils.currentAppVersion()) { result in
            switch result {
            case ApiResult.Success(let JSONdata):
                
                let wrapper = AppOpenResponseWrapper(dictionary: JSONdata)
                
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
                
            case let ApiResult.Error(_, error, rawResponse):
                if NStack.sharedInstance.configuration.verboseMode {
                    print("failure: \(rawResponse ?? "unknown error")")
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