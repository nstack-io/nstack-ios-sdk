//
//  NStack.swift
//  NStack
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class NStack {
    
    /// The singleton object which should be used to interact with NStack API.
    public static let sharedInstance = NStack()

    /// The configuration object the shared instance have been initialized with.
    public fileprivate(set) var configuration: Configuration!

    /// The manager responsible for fetching, updating and persisting translations.
    public fileprivate(set) var translationsManager: TranslationManagerType?

    #if os(iOS) || os(tvOS)
    /// The manager responsible for handling and showing version alerts and messages.
    public fileprivate(set) var alertManager: AlertManager!
    #endif

    /// This gets called when the phone language has changed while app is running.
    /// At this point, translations have been updated, if there was an internet connection.
    public var languageChangedHandler: (() -> Void)?

    /// Description
    public var logLevel: LogLevel = .error {
        didSet {
            logger.logLevel = logLevel
            // FIXME: Fix logger in translations
            //translationsManager?.logger.logLevel = logLevel
        }
    }

    #if os(macOS) || os(watchOS)
    public typealias LaunchOptionsKeyType = String
    internal var avoidUpdateList: [LaunchOptionsKeyType] = []
    #else
    public typealias LaunchOptionsKeyType = UIApplication.LaunchOptionsKey
    internal var avoidUpdateList: [LaunchOptionsKeyType] = [.location]
    #endif

    internal var connectionManager: ConnectionManager!
    internal fileprivate(set) var configured = false
    internal var observer: ApplicationObserver?
    internal var logger: LoggerType = ConsoleLogger()

    // FOX
//    public private(set) var timeZones: [Timezone]? {
//        didSet {
//            guard let timeZones = timeZones else {
//                // Delete from disk
//
//                return
//            }
//
//            // Write to disk
//            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
//            let data = try? encoder.encode(timeZones)
//            try? data?.write(to: <#T##URL#>, options: [.atomic])
//        }
//    }
    
    // MARK: - Start NStack -

    fileprivate init() {}

    /// Initializes NStack and, if `updateAutomaticallyOnStart` is set on the passed `Configuration`
    /// object, fetches all data (including translations if enabled) from NStack API right away.
    ///
    /// - Parameters:
    ///   - configuration: A `Configuration` struct containing API keys and translations type.
    ///   - launchOptions: Launch options passed from `applicationDidFinishLaunching:` function.
    public class func start(configuration: Configuration,
                            launchOptions: [LaunchOptionsKeyType: Any]?) {
        sharedInstance.start(configuration: configuration, launchOptions: launchOptions)
    }

    fileprivate func start(configuration: Configuration,
                           launchOptions: [LaunchOptionsKeyType: Any]?) {
        guard !configured else {
            logger.log("NStack is already configured. Kill the app and start it again with new configuration.",
                level: .error)
            return
        }

        self.configuration = configuration
        self.configured = true

        // For testing purposes
        VersionUtilities.versionOverride = configuration.versionOverride

        // Setup the connection manager
        let apiConfiguration = APIConfiguration(
            appId: configuration.appId,
            restAPIKey: configuration.restAPIKey,
            isFlat: configuration.flat,
            translationsUrlOverride: configuration.translationsUrlOverride
        )
        connectionManager = ConnectionManager(configuration: apiConfiguration)

        // Observe if necessary
        if configuration.updateOptions.contains(.onDidBecomeActive) {
            observer = ApplicationObserver(handler: { (action) in
                guard action == .didBecomeActive else { return }

                self.update { error in
                    if let error = error {
                        self.logger.logError("Error updating NStack on did become active: " +
                            error.localizedDescription)
                        return
                    }
                }
            })
        }

        #if os(iOS) || os(tvOS)
        // Setup alert manager
        alertManager = AlertManager(repository: connectionManager)
        #endif

        // Update if necessary and launch options doesn't contain a key present in avoid update list
        if configuration.updateOptions.contains(.onStart) &&
            launchOptions?.keys.contains(where: { self.avoidUpdateList.contains($0) }) != true &&
            !configuration.updateOptions.contains(.never) {
            update()
        }
    }
    
    func setupTranslations<T: Translatable>(type: T.Type) {
        // Setup translations
        let manager = TranslationManager<T>(repository: connectionManager, logger: ConsoleLogger())
        
        // Delete translations if new version
        if VersionUtilities.isVersion(VersionUtilities.currentAppVersion,
                                      greaterThanVersion: VersionUtilities.previousAppVersion) {
            manager.clearTranslations(includingPersisted: true)
        }
        
        // Set callback
        manager.languageChangedAction = {
            self.languageChangedHandler?()
        }
        
        translationsManager = manager
    }

    /// Fetches the latest data from the NStack server and updates accordingly.
    ///
    /// - Shows appropriate notifications to the user (Update notifications, what's new, messages, rate reminders).
    /// - Updates the translation strings for current language.
    ///
    /// *Note:* By default, this is automatically invoked after *NStack.start()* has been called and subsequently on applicationDidBecomeActive.
    /// To override this behavior, see the properties on the *configuration* struct.
    ///
    /// - Parameter completion: This is run after the call has finished. 
    ///                         If *error* was nil, translation strings are up-to-date.
    public func update(_ completion: ((_ error: NStackError.Manager?) -> Void)? = nil) {
        guard configured else {
            print(NStackError.Manager.notConfigured.description)
            completion?(.notConfigured)
            return
        }

        // FIXME: Refactor

        connectionManager.postAppOpen(completion: { result in
            switch result {
            case .success(let appOpenResponse):
                guard let appOpenResponseData = appOpenResponse.data else { return }

                // Update translations
//                if let translations = appOpenResponseData.translate, translations.count > 0 {
//                    self.translationsManager?.set(translationsDictionary: translations)
//                }

                #if os(iOS) || os(tvOS)

                if !self.alertManager.alreadyShowingAlert {

                    if let newVersion = appOpenResponseData.update?.newerVersion {
                        self.alertManager.showUpdateAlert(newVersion: newVersion)
                    } else if let changelog = appOpenResponseData.update?.newInThisVersion {
                        self.alertManager.showWhatsNewAlert(changelog)
                    } else if let message = appOpenResponseData.message {
                        self.alertManager.showMessage(message)
                    } else if let rateReminder = appOpenResponseData.rateReminder {
                        self.alertManager.showRateReminder(rateReminder)
                    }

                    VersionUtilities.previousAppVersion = VersionUtilities.currentAppVersion
                }
                #endif

                self.connectionManager.setLastUpdated()

            case let .failure(error):
                // FIXME: Fix logging
//                self.logger.log("Failure: \(response.response?.description ?? "unknown error")", level: .error)
                completion?(.updateFailed(reason: error.localizedDescription))
            }
        })

        // Update translations if needed
        // FIXME: Fix updating translations
        // translationsManager?.updateTranslations()
    }
}

// MARK: - Geography -

public extension NStack {
    
    // MARK: - IPAddress
    
    /// Retrieve details based on the requestee's ip address
    ///
    /// - Parameter completion: Completion block when the API call has finished.
    public func ipDetails(completion: @escaping Completion<IPAddress>) {
        connectionManager.fetchIPDetails(completion: completion)
    }
    
    // MARK: - Countries
    
    /// Updates the list of countries stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateCountries(completion: @escaping Completion<[Country]>) {
        connectionManager.fetchCountries(completion: completion)
    }
    
    /// Locally stored list of countries
    public private(set) var countries: [Country]? {
        get {
            // FIXME: Load from disk on load
            return nil
//            return Constants.persistentStore.serializableForKey(Constants.CacheKeys.countries)
        }
        set {
            // FIXME: Save to disk or delete
//            guard let newValue = newValue else {
//                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.countries, purgeMemoryCache: true)
//                return
//            }
//            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.countries)
        }
    }
    
    // MARK: - Continents
    
    /// Updates the list of continents stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateContinents(completion: @escaping Completion<[Continent]>) {
        connectionManager.fetchContinents(completion: completion)
    }
    
    /// Locally stored list of continents
    public private(set) var continents: [Continent]? {
        get {
            // FIXME: Load from disk on start
//            return Constants.persistentStore.serializableForKey(Constants.CacheKeys.continents)
            return nil
        }
        set {
            // FIXME: Save/delete to disk
//            guard let newValue = newValue else {
//                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.continents, purgeMemoryCache: true)
//                return
//            }
//            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.continents)
        }
    }
    
    // MARK: - Languages
    
    /// Updates the list of languages stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateLanguages(completion: @escaping Completion<[Language]>) {
        connectionManager.fetchLanguages(completion: completion)
    }
    
    /// Locally stored list of languages
    public private(set) var languages: [Language]? {
        get {
            // FIXME: Load from disk on start
            //return Constants.persistentStore.serializableForKey(Constants.CacheKeys.languanges)
            return nil
        }
        set {
            // FIXME: Save/delete to disk
//            guard let newValue = newValue else {
//                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.languanges, purgeMemoryCache: true)
//                return
//            }
//            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.languanges)
        }
    }
    
    // MARK: - Timezones
    
    /// Updates the list of timezones stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateTimezones(completion: ((_ countries: [Timezone], _ error: Error?) -> ())? = nil) {
        connectionManager.fetchTimeZones { (result) in
            switch result {
            case .success(let data):
                self.timezones = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            }
        }
    }
    
    /// Locally stored list of timezones
    public private(set) var timezones: [Timezone]? {
        get {
            // FIXME: Load from disk on start
//            return Constants.persistentStore.serializableForKey(Constants.CacheKeys.timezones)
            return nil
        }
        set {
            // FIXME: Save/delete to disk
//            guard let newValue = newValue else {
//                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.timezones, purgeMemoryCache: true)
//                return
//            }
//            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.timezones)
        }
    }
    
    /// Get timezone for latitude and longitude
    ///
    /// - Parameters
    ///     lat: A double representing the latitude
    ///     lgn: A double representing the longitude
    ///     completion: Completion block when the API call has finished.
    public func timezone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        connectionManager.fetchTimeZone(lat: lat, lng: lng, completion: completion)
    }
}

// MARK: - Validation -

public extension NStack {
    
    /// Validate an email.
    ///
    /// - Parameters
    ///     email: A string to be validated as a email
    ///     completion: Completion block when the API call has finished.
    public func validateEmail(_ email:String, completion: @escaping ((_ valid: Bool, _ error: Error?) -> ())) {
        connectionManager.validateEmail(email) { (result) in
            switch result {
            case .success(let data):
                completion(data.ok, nil)
            case .failure(let error):
                completion(false,error)
            }
        }
    }
}

// MARK: - Content -

public extension NStack {
    /// Get content response for slug made on NStack web console
    ///
    /// - Parameters
    ///     slug: The string slug of the required content response
    ///     unwrapper: Optional unwrapper where to look for the required data, default is in the data object
    ///     completion: Completion block with the response as a any object if successful or error if not
    public func getContentResponse<T: Codable>(_ slug: String, key: String? = nil,
                                               completion: @escaping Completion<T>) {
        connectionManager.fetchStaticResponse(slug, completion: completion)
    }
}

// MARK: - Collections -
public extension NStack {
    /// Get collection content for id made on NStack web console
    ///
    /// - Parameters
    ///     id: The integer id of the required collection
    ///     unwrapper: Optional unwrapper where to look for the required data, default is in the data object
    ///     key: Optional string if only one property or object is required, default is nil
    ///     completion: Completion block with the response as a any object if successful or error if not
    public func fetchCollectionResponse<T: Codable>(for id: Int, completion: @escaping Completion<T>) {
        connectionManager.fetchCollection(id, completion: completion)
    }
}

