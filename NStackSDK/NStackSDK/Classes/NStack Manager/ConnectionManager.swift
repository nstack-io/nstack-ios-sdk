//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import TranslationManager

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
final class ConnectionManager: Repository {

    private let baseURLv1 = "https://nstack.io/api/v1/"
    private let baseURLv2 = "https://nstack.io/api/v2/"
    private let session: URLSession
    private let configuration: APIConfiguration

    var defaultHeaders: [String: String] {
        return [
            "X-Application-id": configuration.appId,
            "X-Rest-Api-Key": configuration.restAPIKey
        ]
    }

    init(configuration: APIConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 20.0

        self.session = URLSession(configuration: sessionConfiguration)
        self.configuration = configuration
    }
}

// MARK: - AppOpenRepository
extension ConnectionManager {
    func postAppOpen(oldVersion: String = VersionUtilities.previousAppVersion,
                     currentVersion: String = VersionUtilities.currentAppVersion,
                     acceptLanguage: String? = nil, completion: @escaping Completion<AppOpenResponse>) {
        var params: [String: Any] = [
            "version": currentVersion,
            "guid": Configuration.guid,
            "platform": "ios",
            "last_updated": ConnectionManager.lastUpdatedString,
            "old_version": oldVersion
        ]

        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }

        var headers = defaultHeaders
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }
        headers["N-Meta"] = configuration.nmeta.current

        let url = baseURLv2 + "open" + (configuration.isFlat ? "?flat=true" : "")

        let request = session.request(url, method: .post, parameters: params, headers: headers)
        session.startDataTask(with: request, completionHandler: completion)
    }
}
// MARK: - TranslationRepository
extension ConnectionManager {
    func getLocalizationConfig<C>(acceptLanguage: String, lastUpdated: Date?, completion: @escaping (Result<[C]>) -> Void) where C: LocalizationModel {
        var params: [String: Any] = [
            "guid": Configuration.guid,
            "platform": "ios",
            "last_updated": ConnectionManager.lastUpdatedString
        ]

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let url = baseURLv2 + "localize/resources/platforms/mobile" + (configuration.isFlat ? "?flat=true" : "")

        let request = session.request(url, method: .get, parameters: params, headers: headers)
        let localizationCompletion: (Result<[Localization]>) -> Void = { (response) in
            completion(response as! Result<[C]>)
        }
        session.startDataTask(with: request, completionHandler: localizationCompletion)
    }

    func getTranslations<L>(localization: LocalizationModel, acceptLanguage: String, completion: @escaping (Result<TranslationResponse<L>>) -> Void) where L: LanguageModel {
        var params: [String: Any] = [
            "guid": Configuration.guid,
            "platform": "ios"
        ]
        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let url = localization.url
        let request = session.request(url, method: .get, parameters: params, headers: headers)
        let languageCompletion: (Result<TranslationResponse<Language>>) -> Void = { (response) in
            completion(response as! Result<TranslationResponse<L>>)
        }
        session.startDataTask(with: request, completionHandler: languageCompletion)
    }

    func getAvailableLanguages<L>(completion: @escaping (Result<[L]>) -> Void) where L: LanguageModel {
        let lang = Language(id: 1, name: "English", direction: "lrm", acceptLanguage: "en-GB", isDefault: true, isBestFit: true)
        completion(.success([lang] as! [L]))
    }
}
//    
//    func fetchTranslations(acceptLanguage: String,
//                           completion: @escaping Completion<TranslationsResponse>) {
//        let params: [String : Any] = [
//            "guid"              : Configuration.guid,
//            "last_updated"      : ConnectionManager.lastUpdatedString
//        ]
//
//        let url = configuration.translationsUrlOverride ?? baseURL + "translate/mobile/keys?all=true" + (configuration.isFlat ? "&flat=true" : "")
//
//        var headers = defaultHeaders
//        headers["Accept-Language"] = acceptLanguage
//
//        let request = session.request(url, parameters: params, headers: headers)
//        session.startDataTask(with: request, completionHandler: completion)
//    }
//
//    func fetchCurrentLanguage(acceptLanguage: String,
//                              completion:  @escaping Completion<Language>) {
//        let params: [String : Any] = [
//            "guid"              : Configuration.guid,
//            "last_updated"      : ConnectionManager.lastUpdatedString
//        ]
//
//        let url = baseURL + "translate/mobile/languages/best_fit?show_inactive_languages=true"
//
//        var headers = defaultHeaders
//        headers["Accept-Language"] = acceptLanguage
//
//        let request = session.request(url, parameters: params, headers: headers)
//        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
//    }
//
//    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>) {
//        let params: [String : Any] = ["guid" : Configuration.guid]
//        let url = baseURL + "translate/mobile/languages"
//
//        let request = session.request(url, parameters: params, headers: defaultHeaders)
//        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
//    }
//
//    func fetchPreferredLanguages() -> [String] {
//        return Locale.preferredLanguages
//    }
//
//    func fetchBundles() -> [Bundle] {
//        return Bundle.allBundles
//    }
//}
// MARK: - LocalizationContextRepository
extension ConnectionManager {
    func fetchPreferredLanguages() -> [String] {
        return Locale.preferredLanguages
    }

    func getLocalizationBundles() -> [Bundle] {
        return Bundle.allBundles
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return nil
    }
}

// MARK: - UpdatesRepository
extension ConnectionManager {
    func fetchUpdates(oldVersion: String = VersionUtilities.previousAppVersion,
                      currentVersion: String = VersionUtilities.currentAppVersion,
                      completion: @escaping Completion<Update>) {
        let params: [String: Any] = [
            "current_version": currentVersion,
            "guid": Configuration.guid,
            "platform": "ios",
            "old_version": oldVersion
            ]

        let url = baseURLv1 + "notify/updates"

        let request = session.request(url, parameters: params, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}
// MARK: - VersionsRepository
extension ConnectionManager {
    func markWhatsNewAsSeen(_ id: Int) {
        let params: [String: Any] = [
            "guid": Configuration.guid,
            "update_id": id,
            "type": "new_in_version",
            "answer": "no"
        ]

        let url = baseURLv1 + "notify/updates/views"

        // FIXME: Refactor
        let request = session.request(url, method: .post, parameters: params, headers: defaultHeaders)
        session.dataTask(with: request).resume()
    }

    func markMessageAsRead(_ id: Int) {
        let params: [String: Any] = [
            "guid": Configuration.guid,
            "message_id": id
        ]

        let url = baseURLv1 + "notify/messages/views"
        let request = session.request(url, method: .post, parameters: params, headers: defaultHeaders)
        session.dataTask(with: request).resume()
    }

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String: Any] = [
            "guid": Configuration.guid,
            "platform": "ios",
            "answer": answer.rawValue
        ]

        let url = baseURLv1 + "notify/rate_reminder/views"
        let request = session.request(url, method: .post, parameters: params, headers: defaultHeaders)
        session.dataTask(with: request).resume()
    }
    #endif
}
// MARK: - GeographyRepository
extension ConnectionManager {
    func fetchContinents(completion: @escaping Completion<[Continent]>) {
        let url = baseURLv1 + "geographic/continents"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchLanguages(completion: @escaping Completion<[Language]>) {
        let url = baseURLv1 + "geographic/languages"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {
        let url = baseURLv1 + "geographic/time_zones"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        let url = baseURLv1 + "geographic/time_zones/by_lat_lng"
        let parameters: [String: Any] = ["lat_lng": "\(String(lat)),\(String(lng))"]
        let request = session.request(url, parameters: parameters, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        let url = baseURLv1 + "geographic/ip-address"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }

    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        let url = baseURLv1 + "geographic/countries"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}
// MARK: - ValidationRepository
extension ConnectionManager {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>) {
        let parameters: [String: Any] = ["email": email]
        let url = baseURLv1 + "validator/email"
        let request = session.request(url, parameters: parameters, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}
// MARK: - ContentRepository
extension ConnectionManager {
    func fetchStaticResponse<T: Codable>(_ slug: String, completion: @escaping Completion<T>) {
        let url = baseURLv1 + "content/responses/\(slug)"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, completionHandler: completion)
    }
}
// MARK: - ColletionRepository
extension ConnectionManager {
    func fetchCollection<T: Codable>(_ id: Int, completion: @escaping ((Result<T>) -> Void)) {
        let url = baseURLv1 + "content/collections/\(id)"
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
