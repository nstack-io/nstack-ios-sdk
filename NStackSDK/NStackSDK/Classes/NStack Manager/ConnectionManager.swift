//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

struct DataModel<T: Codable>: WrapperModelType {
    let model: T
    
    enum CodingKeys: String, CodingKey {
        case model = "data"
    }
}

protocol WrapperModelType: Codable {
    associatedtype ModelType: Codable
    var model: ModelType { get }
}

// FIXME: Figure out how to do accept language header properly
final class ConnectionManager {
    private let baseURL = "https://nstack.io/api/v1/"
    private let session: URLSession
    private let configuration: APIConfiguration

    var defaultHeaders: [String : String] {
        return [
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey,
        ]
    }

    init(configuration: APIConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 20.0

        self.session = URLSession(configuration: sessionConfiguration)
        self.configuration = configuration
    }
}

extension ConnectionManager: AppOpenRepository {
    func postAppOpen(oldVersion: String = VersionUtilities.previousAppVersion,
                     currentVersion: String = VersionUtilities.currentAppVersion,
                     acceptLanguage: String? = nil, completion: @escaping Completion<AppOpenResponse>) {
        var params: [String : Any] = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "last_updated"      : ConnectionManager.lastUpdatedString,
            "old_version"       : oldVersion
        ]

        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }

        var headers = defaultHeaders
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }

        let url = baseURL + "open" + (configuration.isFlat ? "?flat=true" : "")

        let request = session.request(url, method: .post, parameters: params, headers: headers)
        session.startDataTask(with: request, completionHandler: completion)
    }
}

extension ConnectionManager: TranslationsRepository {
    func fetchTranslations(acceptLanguage: String,
                           completion: @escaping Completion<TranslationsResponse>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        let url = configuration.translationsUrlOverride ?? baseURL + "translate/mobile/keys?all=true" + (configuration.isFlat ? "&flat=true" : "")

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let request = session.request(url, parameters: params, headers: headers)
        session.startDataTask(with: request, completionHandler: completion)
    }

    func fetchCurrentLanguage(acceptLanguage: String,
                              completion:  @escaping Completion<Language>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        let url = baseURL + "translate/mobile/languages/best_fit?show_inactive_languages=true"

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let request = session.request(url, parameters: params, headers: headers)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>) {
        let params: [String : Any] = ["guid" : Configuration.guid]
        let url = baseURL + "translate/mobile/languages"

        let request = session.request(url, parameters: params, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchPreferredLanguages() -> [String] {
        return Locale.preferredLanguages
    }

    func fetchBundles() -> [Bundle] {
        return Bundle.allBundles
    }
}

extension ConnectionManager: UpdatesRepository {
    func fetchUpdates(oldVersion: String = VersionUtilities.previousAppVersion,
                      currentVersion: String = VersionUtilities.currentAppVersion,
                      completion: @escaping Completion<Update>) {
        let params: [String : Any] = [
            "current_version"   : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "old_version"       : oldVersion,
            ]

        let url = baseURL + "notify/updates"
        
        let request = session.request(url, parameters: params, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}

extension ConnectionManager: VersionsRepository {
    func markWhatsNewAsSeen(_ id: Int) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]

        let url = baseURL + "notify/updates/views"
        
        // FIXME: Refactor
        let request = session.request(url, method: .post, parameters: params, headers: defaultHeaders)
        session.dataTask(with: request).resume()
    }

    func markMessageAsRead(_ id: String) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "message_id"        : id
        ]

        let url = baseURL + "notify/messages/views"
        let request = session.request(url, method: .post, parameters: params, headers: defaultHeaders)
        session.dataTask(with: request).resume()
    }

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]

        let url = baseURL + "notify/rate_reminder/views"
        let request = session.request(url, method: .post, parameters: params, headers: defaultHeaders)
        session.dataTask(with: request).resume()
    }
    #endif
}

// MARK: - Geography -

extension ConnectionManager: GeographyRepository {
    func fetchContinents(completion: @escaping Completion<[Continent]>) {
        let url = baseURL + "geographic/continents"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
    
    func fetchLanguages(completion: @escaping Completion<[Language]>) {
        let url = baseURL + "geographic/languages"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
    
    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {
        let url = baseURL + "geographic/time_zones"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
    
    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        let url = baseURL + "geographic/time_zones/by_lat_lng"
        let parameters: [String: Any] = ["lat_lng" : "\(String(lat)),\(String(lng))"]
        let request = session.request(url, parameters: parameters, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
    
    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        let url = baseURL + "geographic/ip-address"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
    
    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        let url = baseURL + "geographic/countries"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}

// MARK: - Validation -

extension ConnectionManager: ValidationRepository {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>) {
        let parameters: [String: Any] = ["email" : email]
        let url = baseURL + "validator/email"
        let request = session.request(url, parameters: parameters, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}

// MARK: - Content -

extension ConnectionManager: ContentRepository {
    func fetchStaticResponse<T: Codable>(_ slug: String, completion: @escaping Completion<T>) {
        let url = baseURL + "content/responses/\(slug)"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}

// MARK: - Collections -
extension ConnectionManager: ColletionRepository {
    func fetchCollection<T: Codable>(_ id: Int, completion: @escaping ((Result<T>) -> Void)) {
        let url = baseURL + "content/collections/\(id)"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}

// MARK: - Utility Functions -

// FIXME: Refactor

extension ConnectionManager {

    static var lastUpdatedString: String {
        //let cache = Constants.persistentStore

        // FIXME: Handle language change
        // FIXME: Fix this
//        let previousAcceptLanguage = cache.string(forKey: Constants.CacheKeys.prevAcceptedLanguage)
//        let currentAcceptLanguage  = TranslationManager.acceptLanguage()
//
//        if let previous = previousAcceptLanguage, previous != currentAcceptLanguage {
//            cache.setObject(currentAcceptLanguage, forKey: Constants.CacheKeys.prevAcceptedLanguage)
//            setLastUpdated(Date.distantPast)
//        }

//        let key = Constants.CacheKeys.lastUpdatedDate
//        let date = cache.object(forKey: key) as? Date ?? Date.distantPast
//        return date.stringRepresentation()
        return ""
    }

    func setLastUpdated(toDate date: Date = Date()) {
        // FIXME: Implement this
//        Constants.persistentStore.setObject(date, forKey: Constants.CacheKeys.lastUpdatedDate)
    }
}
