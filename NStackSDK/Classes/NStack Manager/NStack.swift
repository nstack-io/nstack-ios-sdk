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
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif


public class NStack {

    /// The singleton object which should be used to interact with NStack API.
    public static let sharedInstance = NStack()

    /// The configuration object the shared instance have been initialized with.
    public fileprivate(set) var configuration: Configuration!

    /// The manager responsible for fetching, updating and persisting localizations.
    public fileprivate(set) var localizationManager: LocalizationWrappable?

    /// The manager responsible for fetching Country, Continent, Language & Timezone configurations
    public fileprivate(set) var geographyManager: GeographyManager?

    /// The manager responsible for validation
    public fileprivate(set) var validationManager: ValidationManager?

    /// The manager responsible for getting custom content and collections availble
    public fileprivate(set) var contentManager: ContentManager?

    /// The manager responsible for feedback
    public fileprivate(set) var feedbackManager: FeedbackManager?

    #if os(iOS) || os(tvOS)
    /// The manager responsible for handling and showing version alerts and messages.
    public fileprivate(set) var alertManager: AlertManager!
    #endif

    /// This gets called when the phone language has changed while app is running.
    /// At this point, localizations have been updated, if there was an internet connection.
    public var languageChangedHandler: ((Locale?) -> Void)?

    /// Description
    public var logLevel: LogLevel = .error {
        didSet {
            logger.logLevel = logLevel
            // FIXME: Fix logger in localizations
            //localizationManager?.logger.logLevel = logLevel
        }
    }

    #if os(macOS) || os(watchOS)
    public typealias LaunchOptionsKeyType = String
    internal var avoidUpdateList: [LaunchOptionsKeyType] = []
    #else
    public typealias LaunchOptionsKeyType = UIApplication.LaunchOptionsKey
    internal var avoidUpdateList: [LaunchOptionsKeyType] = [.location]
    #endif

    internal var repository: Repository!
    internal fileprivate(set) var configured = false
    internal var observer: ApplicationObserver?
    internal var logger: LoggerType = ConsoleLogger()

    // MARK: - Start NStack -

    fileprivate init() {}

    /// Initializes NStack and, if `updateAutomaticallyOnStart` is set on the passed `Configuration`
    /// object, fetches all data (including localizations if enabled) from NStack API right away.
    ///
    /// - Parameters:
    ///   - configuration: A `Configuration` struct containing API keys and localizations type.
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
            isProduction: configuration.isProduction,
            localizationUrlOverride: configuration.localizationUrlOverride,
            nmeta: NMeta(environment: configuration.currentEnvironmentAPIString)
        )
        repository = ConnectionManager(configuration: apiConfiguration)

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

        geographyManager = GeographyManager(repository: repository)
        validationManager = ValidationManager(repository: repository)
        feedbackManager = FeedbackManager(repository: repository)
        contentManager = ContentManager(repository: repository)

        #if os(iOS) || os(tvOS)
        // Setup alert manager
        alertManager = AlertManager(repository: repository)
        #endif

        //sets up localization manager
        setupLocalizations()

        // Update if necessary and launch options doesn't contain a key present in avoid update list
        if configuration.updateOptions.contains(.onStart) &&
            launchOptions?.keys.contains(where: { self.avoidUpdateList.contains($0) }) != true &&
            !configuration.updateOptions.contains(.never) {
            update()
        }
    }

    func setupLocalizations() {
        // Setup localizations
        let manager = LocalizationManager<DefaultLanguage, LocalizationConfig>(repository: repository,
                                                                  contextRepository: repository,
                                                                  localizableModel: configuration.localizationClass,
                                                                  updateMode: .manual)

        // Delete translations if new version
        if VersionUtilities.isVersion(VersionUtilities.currentAppVersion,
                                      greaterThanVersion: VersionUtilities.previousAppVersion) {
            do {
                try manager.clearLocalizations(includingPersisted: true)
            } catch {
                #warning("Handle catch here")
            }
        }

        // Set callback
        manager.delegate = self
        localizationManager = LocalizationWrapper(localizationManager: manager)
    }

    /// Fetches the latest data from the NStack server and updates accordingly.
    ///
    /// - Shows appropriate notifications to the user (Update notifications, what's new, messages, rate reminders).
    /// - Updates the localization strings for current language.
    ///
    /// *Note:* By default, this is automatically invoked after *NStack.start()* has been called and subsequently on applicationDidBecomeActive.
    /// To override this behavior, see the properties on the *configuration* struct.
    ///
    /// - Parameter completion: This is run after the call has finished.
    ///                         If *error* was nil, localization strings are up-to-date.
    // swiftlint:disable:next cyclomatic_complexity
    public func update(_ completion: ((_ error: NStackError.Manager?) -> Void)? = nil) {
        guard configured else {
            print(NStackError.Manager.notConfigured.description)
            completion?(.notConfigured)
            return
        }

        // FIXME: Refactor
        let acceptLanguageProvider = AcceptLanguageProvider(repository: repository)
        let header = acceptLanguageProvider.createHeaderString(languageOverride: localizationManager?.languageOverride)
        repository.postAppOpen(oldVersion: VersionUtilities.previousAppVersion,
                               currentVersion: VersionUtilities.currentAppVersion,
                               acceptLanguage: header,
                               completion: { result in
            switch result {
            case .success(let appOpenResponse):
                guard let appOpenResponseData = appOpenResponse.data else { return }

                // Update localizations
                if let localizations = appOpenResponseData.localize {
                    self.localizationManager?.handleLocalizationModels(configs: localizations,
                                                                       acceptHeaderUsed: header,
                                                                       completion: { (error) in
                                                                        if error != nil {
                                                                            //if error, try to update translations in Translations Manager
                                                                            self.localizationManager?.updateLocalizations()
                                                                        } else {
                                                                            VersionUtilities.lastUpdatedIso8601DateString = Date().iso8601
                                                                            completion?(nil)
                                                                        }
                    })
                }

                #if os(iOS) || os(tvOS)
                DispatchQueue.main.async {
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
                }
                #endif
            case let .failure(error):
                completion?(.updateFailed(reason: error.localizedDescription))
            }
        })
    }

    /// Sends the proposal to NStack
    ///
    /// - Parameters:
    ///   - section: The section where the key belongs
    ///   - key: The actual key for the text
    ///   - value: The new value for the key
    ///   - locale: The locale it should affect
    func storeProposal(for identifier: LocalizationItemIdentifier, with value: String, completion: @escaping ((_ error: NStackError.Localization?) -> Void)) {
        guard let language = localizationManager?.bestFitLanguage else {
            completion(.updateFailed(reason: "No best fit language"))
            return
        }
        let locale = language.locale

        repository.storeProposal(section: identifier.section, key: identifier.key, value: value, locale: locale.identifier) { (result) in
            switch result {
            case .success(let response):
                guard
                    let identifier = SectionKeyHelper.transform(SectionKeyHelper.combine(section: response.section,
                                                                                         key: response.key)),
                    let locale = response.locale
                    else {
                        completion(.updateFailed(reason: "Identifier/Locale from response could not be found."))
                        return
                }
                self.localizationManager?.storeProposal(response.value, locale: locale, for: identifier)
                completion(nil)
            case .failure(let error):
                self.logger.logError("NStack failed storing proposal: " + error.localizedDescription)
                completion(.updateFailed(reason: error.localizedDescription))
            }
        }
    }

    /// Fetches all proposals returns as an array of Proposal
    ///
    /// - Parameter completion: returns an array of Proposal
    func fetchProposals(completion: @escaping ([Proposal]?) -> Void) {
        repository.fetchProposals { (result) in
            switch result {
            case .success(let response):
                completion(response)
            case .failure(let error):
                completion(nil)
                self.logger.logError("NStack failed getting all proposals: " + error.localizedDescription)
            }
        }
    }

    /// Deletes a proposal
    ///
    /// - Parameters:
    ///   - proposal: The proposal you want to delete
    ///   - completion: Gives you either a ProposalDeletion-object including a message, or an Error
    func deleteProposal(_ proposal: Proposal, completion: @escaping (Result<ProposalDeletion>) -> Void) {
        repository.deleteProposal(proposal) { (result) in
            completion(result)
        }
    }

}

extension NStack: LocalizationManagerDelegate {
    public func localizationManager(languageUpdated: LanguageModel?) {
        print("Language Changed To: \(languageUpdated?.locale.identifier ?? "unknown")")
        localizationManager?.refreshLocalization()
    }
}
