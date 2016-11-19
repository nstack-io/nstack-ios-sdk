//
//  NStack.swift
//  NStack
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import UIKit

open class NStack {

    /// The singleton object which should be used to interact with NStack API.
    open static let sharedInstance = NStack()
    
    /// The configuration object the shared instance have been initialized with.
    open fileprivate(set) var configuration: Configuration!

    /// This gets called when the phone language has changed while app is running.
    /// At this point, translations have been updated, if there was an internet connection.
    open var languageChangedHandler: (() -> Void)?

    fileprivate var avoidUpdateList: [UIApplicationLaunchOptionsKey] = [UIApplicationLaunchOptionsKey.location]

    internal fileprivate(set) var configured = false
    internal var observer: ApplicationObserver?

    // MARK: - Start NStack -

    fileprivate init() {}

    /**
     Initializes NStack and, if `updateAutomaticallyOnStart` is set on the passed `Configuration`
     object, fetches all data (including translations if enabled) from NStack API right away.

     - parameter configuration: A `Configuration` struct containing API keys and translations type.
     - parameter launchOptions: Launch options passed from `applicationDidFinishLaunching:` func.
     */
    open class func start(configuration: Configuration,
                                           launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        sharedInstance.start(configuration: configuration, launchOptions: launchOptions)
    }

    fileprivate func start(configuration: Configuration,
                                     launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard !configured else {
            print("NStack is already configured. Kill the app and start it again with new configuration.")
            return
        }

        self.configuration = configuration
        self.configured = true

        // For testing purposes
        VersionUtilities.versionOverride = configuration.versionOverride

        // Setup the connection manager
        ConnectionManager.configuration = APIConfiguration(appId: configuration.appId,
                                                           restAPIKey: configuration.restAPIKey,
                                                           isFlat: configuration.flat)

        // Observe if necessary
        if configuration.updateOptions.contains(.OnDidBecomeActive) {
            observer = ApplicationObserver()
        }

        // Setup translations
        if let translationsClass = configuration.translationsClass {
            TranslationManager.start(translationsType: translationsClass)

            if VersionUtilities.isVersion(VersionUtilities.currentAppVersion(),
                                            greaterThanVersion: VersionUtilities.previousAppVersion()) {
                TranslationManager.sharedInstance.clearSavedTranslations()
            }
        }

        // Update if necessary and launch options doesn't contain a key present in avoid update list
        if configuration.updateOptions.contains(.OnStart) && launchOptions?.keys.contains(where: { self.avoidUpdateList.contains($0) }) != true {
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
    
    open func update(_ completion: ((_ error: NStackError.Manager?) -> Void)? = nil) {
        guard configured else {
            print(NStackError.Manager.notConfigured.description)
            completion?(.notConfigured)
            return
        }

        ConnectionManager.postAppOpen(completion: { response in
            switch response.result {
            case .success(let JSONdata):
                guard let dictionary = JSONdata as? NSDictionary else {
                    self.print("Failure: couldn't parse response. Response data: ", JSONdata)
                    completion?(.updateFailed(reason: "Couldn't parse response dictionary."))
                    return
                }

                let wrapper = AppOpenResponse(dictionary: dictionary)
                self.print("App open response wrapper: ", wrapper)

                defer {
                    completion?(nil)
                }

                guard let appOpenResponseData = wrapper.data else { return }
                    
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
                    
                    VersionUtilities.setPreviousAppVersion(VersionUtilities.currentAppVersion())
                }

                // Get last fetched language
                if let language = wrapper.languageData?.language {
                    TranslationManager.sharedInstance.lastFetchedLanguage = language
                }
                
                ConnectionManager.setLastUpdatedToNow()

            case let .failure(error):
                self.print("Failure: \(response.response?.description ?? "unknown error")")
                completion?(.updateFailed(reason: error.localizedDescription))
            }
        })
    }
}

//MARK: - Geography
public extension NStack {

    /**
     Updates the list of countries stored by NStack

     - parameter completion: Optional completion block when the API call has finished.
     */
    public static func updateCountries(completion: ((_ countries: [Country], _ error: Error?) -> ())? = nil) {
        ConnectionManager.fetchCountries { (response) in
            switch response.result {
            case .success(let data):
                countries = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            }
        }
    }

    /// Locally stored list of countries
    public static private(set) var countries: [Country]? {
        get {
            return persistentStore.serializableForKey(NStackConstants.CountriesKey)
        }
        set {
            guard let newValue = newValue else {
                persistentStore.deleteSerializableForKey(NStackConstants.CountriesKey, purgeMemoryCache: true)
                return
            }
            persistentStore.setSerializable(newValue, forKey: NStackConstants.CountriesKey)
        }
    }
}
