//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Alamofire
import Serpent
import Cashier

// FIXME: Figure out how to do accept language header properly

final class ConnectionManager {
    let baseURL = "https://nstack.io/api/v1/"
    let defaultUnwrapper: Parser.Unwrapper = { $0.0["data"] }

    let manager: SessionManager
    let configuration: APIConfiguration

    var defaultHeaders: [String : String] {
        return [
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey
        ]
    }

    init(configuration: APIConfiguration) {
        let sessionConfiguration = SessionManager.default.session.configuration
        sessionConfiguration.timeoutIntervalForRequest = 20.0

        self.manager = SessionManager(configuration: sessionConfiguration)
        self.configuration = configuration
    }
}

extension ConnectionManager: AppOpenRepository {
    func postAppOpen(oldVersion: String = VersionUtilities.previousAppVersion(),
                     currentVersion: String = VersionUtilities.currentAppVersion(),
                     acceptLanguage: String = TranslationManager.acceptLanguageHeaderValueString(),
                     completion: @escaping Completion<Any>) {
        var params: [String : Any] = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "last_updated"      : lastUpdatedString(),
            "old_version"       : oldVersion
        ]

        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let url = baseURL + "open" + (configuration.isFlat ? "?flat=true" : "")

        manager
            .request(url, method: .post, parameters: params, headers: headers)
            .responseJSON(completionHandler: completion)
    }
}

extension ConnectionManager: TranslationsRepository {
    func fetchTranslations(acceptLanguage: String,
                           completion: @escaping Completion<TranslationsResponse>) {
        let params: [String : Any] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            "last_updated"      : lastUpdatedString()
        ]

        let url = baseURL + "translate/mobile/keys" + (configuration.isFlat ? "?flat=true" : "")

        manager
            .request(url, method: .get, parameters:params, headers: defaultHeaders)
            .responseSerializable(completion)
    }

    func fetchCurrentLanguage(completion:  @escaping Completion<Language>) {
        let params: [String : Any] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            "last_updated"      : lastUpdatedString(),
            ]

        let url = baseURL + "translate/mobile/languages/best_fit?show_inactive_languages=true"

        manager
            .request(url, method: .get, parameters: params, headers: defaultHeaders)
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }

    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>) {
        let params: [String : Any] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            ]

        let url = baseURL + "translate/mobile/languages"

        manager
            .request(url, method: .get, parameters:params, headers: defaultHeaders)
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

extension ConnectionManager: UpdatesRepository {
    func fetchUpdates(oldVersion: String = VersionUtilities.previousAppVersion(),
                      currentVersion: String = VersionUtilities.currentAppVersion(),
                      completion: @escaping Completion<Update>) {
        let params: [String : Any] = [
            "current_version"   : currentVersion,
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "old_version"       : oldVersion,
            ]

        let url = baseURL + "notify/updates"
        manager
            .request(url, method: .get, parameters:params, headers: defaultHeaders)
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

extension ConnectionManager: VersionsRepository {
    func markNewerVersionAsSeen(_ id: Int, appStoreButtonPressed:Bool) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "answer"            : (appStoreButtonPressed ? "yes" : "no"),
            "type"              : "newer_version"
        ]

        let url = baseURL + "notify/updates/views"
        manager.request(url, method: .post, parameters:params, headers: defaultHeaders)
    }

    func markWhatsNewAsSeen(_ id: Int) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]

        let url = baseURL + "notify/updates/views"
        manager.request(url, method: .post, parameters:params, headers: defaultHeaders)
    }

    func markMessageAsRead(_ id: String) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid(),
            "message_id"        : id
        ]

        let url = baseURL + "notify/messages/views"
        manager.request(url, method: .post, parameters:params, headers: defaultHeaders)
    }

    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]

        let url = baseURL + "notify/rate_reminder/views"
        manager.request(url, method: .post, parameters:params, headers: defaultHeaders)
    }
}

// MARK: - Geography -

extension ConnectionManager: GeographyRepository {
    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        manager
            .request(baseURL + "geographic/countries", headers: defaultHeaders)
            .responseSerializable(completion, unwrapper: defaultUnwrapper)
    }
}

// MARK: - Utility Functions -

// FIXME: Refactor

extension ConnectionManager {

    func lastUpdatedString() -> String {
        let cache = NStack.sharedInstance.persistentStore
        let currentAcceptLangString = TranslationManager.acceptLanguageHeaderValueString()

        if let prevAcceptLangString = cache.object(forKey: NStackConstants.prevAcceptedLanguageKey) as? String,
            prevAcceptLangString != currentAcceptLangString {

            cache.setObject(currentAcceptLangString, forKey: NStackConstants.prevAcceptedLanguageKey)
            self.setLastUpdatedToDistantPast()
        }

        let date = cache.object(forKey: NStackConstants.lastUpdatedDateKey) as? Date ?? Date.distantPast
        return date.stringRepresentation()
    }

    func setLastUpdatedToNow() {
        NStack.sharedInstance.persistentStore.setObject(Date(), forKey: NStackConstants.lastUpdatedDateKey)
    }
    
    func setLastUpdatedToDistantPast() {
        NStack.sharedInstance.persistentStore.setObject(Date.distantPast, forKey: NStackConstants.lastUpdatedDateKey)
    }
}
