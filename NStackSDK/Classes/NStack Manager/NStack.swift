//
//  NStack.swift
//  NStack
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import UIKit

public class NStack {

    /// The singleton object which should be used to interact with NStack API.
    public static let sharedInstance = NStack()
    
    /// The configuration object the shared instance have been initialized with.
    public private(set) var configuration: Configuration!

    /// This gets called when the phone language has changed while app is running.
    /// At this point, translations have been updated, if there was an internet connection.
    public var languageChangedHandler: (() -> Void)?

    private var avoidUpdateList: [NSObject] = [UIApplicationLaunchOptionsLocationKey]

    internal private(set) var configured = false
    internal var observer: ApplicationObserver?

    // MARK: - Start NStack -

    private init() {}

    /**
     Initializes NStack and, if `updateAutomaticallyOnStart` is set on the passed `Configuration`
     object, fetches all data (including translations if enabled) from NStack API right away.

     - parameter configuration: A `Configuration` struct containing API keys and translations type.
     - parameter launchOptions: Launch options passed from `applicationDidFinishLaunching:` func.
     */
    public class func start(configuration configuration: Configuration,
                                           launchOptions: [NSObject: AnyObject]?) {
        sharedInstance.start(configuration: configuration, launchOptions: launchOptions)
    }

    private func start(configuration configuration: Configuration,
                                     launchOptions: [NSObject: AnyObject]?) {

        self.configuration = configuration
        self.configured = true

        // Observe if necessary
        if configuration.updatesOnApplicationDidBecomeActive {
            observer = ApplicationObserver()
        } else {
            observer = nil
        }

        // Setup translations
        if let translationsClass = configuration.translationsClass {
            TranslationManager.start(translationsType: translationsClass)

            if NStackVersionUtils.isVersion(NStackVersionUtils.currentAppVersion(),
                                            greaterThanVersion: NStackVersionUtils.previousAppVersion()) {
                TranslationManager.sharedInstance.clearSavedTranslations()
            }
        }

        // Update if necessary and launch options doesn't contain a key present in avoid update list
        if configuration.updateAutomaticallyOnStart && launchOptions?.keys.contains({ avoidUpdateList.contains($0) }) != true {
            update()
        }
    }

    /**
    
    Fetches the latest data from the NStack server and updates accordingly.
    
    - Shows appropriate notifications to the user (Update notifications, what's new, messages, rate reminders).
    - Updates the translation strings for current language.
    
    *Note:* By default, this is automatically invoked after *NStack.start()* has been called and subsequently on applicationDidBecomeActive.
    To override this behavior, see the properties on the *configuration* struct.
    
    - parameter completion: This is run after the call has finished. If *error* was nil, translation strings are up-to-date
    
    */
    
    public func update(completion: ((error: NSError?) -> Void)? = nil ) {
        guard configured else {
            print("NStack needs to be configured before it can be used. Please, call the `start` function first.")
            return
        }

        ConnectionManager.postAppOpen(oldVersion: NStackVersionUtils.previousAppVersion(),
                                      currentVersion: NStackVersionUtils.currentAppVersion()) { response in

            switch response.result {
            case .Success(let JSONdata):
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
                        TranslationManager.sharedInstance.setTranslationsSource(appOpenResponseData.translate)
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
                    
                    ConnectionManager.setLastUpdatedToNow()
                }
                
                completion?(error: nil)
                
            case let .Failure(error):
                if NStack.sharedInstance.configuration.verboseMode {
                    print("failure: \(response.response ?? "unknown error")")
                }
                completion?(error: error)
            }
        }
    }
}