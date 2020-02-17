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
import TranslationManager

public class NStack {

    /// The singleton object which should be used to interact with NStack API.
    public static let sharedInstance = NStack()

    /// The configuration object the shared instance have been initialized with.
    public fileprivate(set) var configuration: Configuration!

    /// The manager responsible for fetching, updating and persisting translations.
    public fileprivate(set) var translationsManager: LocalizationWrappable?

    /// The manager responsible for fetching Country, Continent, Language & Timezone configurations
    public fileprivate(set) var geographyManager: GeographyManager?

    /// The manager responsible for validation
    public fileprivate(set) var validationManager: ValidationManager?

    /// The manager responsible for feedback
    public fileprivate(set) var feedbackManager: FeedbackManager?

    /// The manager responsible for getting custom content and collections availble
    public fileprivate(set) var contentManager: ContentManager?

    /// The manager responsible for feedback
    public fileprivate(set) var feedbackManager: FeedbackManager?

    #if os(iOS) || os(tvOS)
    /// The manager responsible for handling and showing version alerts and messages.
    public fileprivate(set) var alertManager: AlertManager!
    #endif

    /// This gets called when the phone language has changed while app is running.
    /// At this point, translations have been updated, if there was an internet connection.
    public var languageChangedHandler: ((Locale?) -> Void)?

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

    internal var repository: Repository!
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
//            try? data?.write(to: , options: [.atomic])
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
            isProduction: configuration.isProduction,
            translationsUrlOverride: configuration.translationsUrlOverride,
            nmeta: NMeta(environment: configuration.currentEnvironmentAPIString)
        )
        repository = configuration.useMock ? MockConnectionManager() : ConnectionManager(configuration: apiConfiguration)

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
        feedbackManager = APIFeedbackManager(repository: repository)

        #if os(iOS) || os(tvOS)
        // Setup alert manager
        alertManager = AlertManager(repository: repository)
        #endif

        //sets up translation manager
        setupTranslations()

        // Update if necessary and launch options doesn't contain a key present in avoid update list
        if configuration.updateOptions.contains(.onStart) &&
            launchOptions?.keys.contains(where: { self.avoidUpdateList.contains($0) }) != true &&
            !configuration.updateOptions.contains(.never) {
            update()
        }
    }

    func setupTranslations() {
        // Setup translations
        let manager = TranslatableManager<Language, Localization>(repository: repository,
                                                                  contextRepository: repository,
                                                                  localizableModel: configuration.translationsClass,
                                                                  updateMode: .manual)

        // Delete translations if new version
        if VersionUtilities.isVersion(VersionUtilities.currentAppVersion,
                                      greaterThanVersion: VersionUtilities.previousAppVersion) {
            do {
                try manager.clearTranslations(includingPersisted: true)
            } catch {
                #warning("Handle catch here")
            }
        }

        // Set callback
        manager.delegate = self
        translationsManager = LocalizationWrapper(translationsManager: manager)
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
        let acceptLanguageProvider = AcceptLanguageProvider(repository: repository)
        let header = acceptLanguageProvider.createHeaderString(languageOverride: translationsManager?.languageOverride)
        repository.postAppOpen(oldVersion: VersionUtilities.previousAppVersion,
                               currentVersion: VersionUtilities.currentAppVersion,
                               acceptLanguage: header,
                               completion: { result in
            switch result {
            case .success(let appOpenResponse):
                guard let appOpenResponseData = appOpenResponse.data else { return }

                // Update translations
                if let localizations = appOpenResponseData.localize {
                    self.translationsManager?.handleLocalizationModels(localizations: localizations,
                                                                       acceptHeaderUsed: header,
                                                                       completion: { (error) in
                                                                        if error != nil {
                                                                            //if error, try to update translations in Translations Manager
                                                                            self.translationsManager?.updateTranslations()
                                                                        } else {
                                                                            VersionUtilities.lastUpdatedIso8601Date = Date().iso8601
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
                // FIXME: Fix logging
//                self.logger.log("Failure: \(response.response?.description ?? "unknown error")", level: .error)
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
    func storeProposal(for identifier: TranslationIdentifier, with value: String) {
        guard let language = translationsManager?.bestFitLanguage else { return }
        let locale = language.acceptLanguage

        repository.storeProposal(section: identifier.section,
                                 key: identifier.key,
                                 value: value,
                                 locale: locale) { (result) in
            switch result {
            case .success(let response):
                guard
                    let identifier = SectionKeyHelper.transform(SectionKeyHelper.combine(section: response.section,
                                                                                           key: response.key)),
                    let locale = response.locale
                else { return }
                self.translationsManager?.storeProposal(response.value, locale: locale, for: identifier)
            case .failure(let error):
                self.logger.logError("NStack failed storing proposal: " + error.localizedDescription)
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

extension NStack: TranslatableManagerDelegate {
    public func translationManager(languageUpdated: LanguageModel?) {
        print("Language Changed To: \(languageUpdated?.locale.identifier ?? "unknown")")
        translationsManager?.refreshTranslations()
    }
}
