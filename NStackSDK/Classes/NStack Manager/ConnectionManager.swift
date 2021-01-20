//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#else
import UIKit
#endif
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif

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
        let sdkVersion = Bundle(for: ConnectionManager.self).releaseVersionNumber ?? ""

        return [
            "X-Application-id": configuration.appId,
            "X-Rest-Api-Key": configuration.restAPIKey,
            "SDK-Version": "ios-\(sdkVersion)"
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
            "last_updated": VersionUtilities.lastUpdatedIso8601DateString,
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

        let url = baseURLv2 + "open"
            + "?test=" + (configuration.isProduction ? "false" : "true")
            + (configuration.isFlat ? "&flat=true" : "")

        let request = session.request(url, method: .post, parameters: params, headers: headers)
        session.startDataTask(with: request, convertFromSnakeCase: false, completionHandler: completion)
    }
}
// MARK: - LocalizationRepository
extension ConnectionManager {
    func getLocalizationDescriptors<D>(acceptLanguage: String, lastUpdated: Date?, completion: @escaping (Result<[D]>) -> Void) where D: LocalizationDescriptor {
        let params: [String: Any] = [
            "guid": Configuration.guid,
            "platform": "ios",
            "last_updated": VersionUtilities.lastUpdatedIso8601DateString,
            "dev": "true"
        ]

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let url = baseURLv2 + "content/localize/resources/platforms/mobile" + (configuration.isFlat ? "?flat=true" : "")

        let request = session.request(url, method: .get, parameters: params, headers: headers)
        let localizationCompletion: (Result<DataModel<[LocalizationConfig]>>) -> Void = { (response) in
            switch response {
            case .success(let data):
                VersionUtilities.lastUpdatedIso8601DateString = Date().iso8601
                let model = data.model
                let result: Result = .success(model)
                completion(result as! Result<[D]>)
            default:
                break
            }
        }
        session.startDataTask(with: request, convertFromSnakeCase: false, completionHandler: localizationCompletion)
    }

    func getLocalization<L, D>(descriptor: D, acceptLanguage: String, completion: @escaping (Result<LocalizationResponse<L>>) -> Void) where L: LanguageModel, D: LocalizationDescriptor {
        let params: [String: Any] = [
            "guid": Configuration.guid,
            "platform": "ios"
        ]
        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        let url = descriptor.url
        let request = session.request(url, method: .get, parameters: params, headers: headers)
        let languageCompletion: (Result<LocalizationResponse<DefaultLanguage>>) -> Void = { (response) in
            completion(response as! Result<LocalizationResponse<L>>)
        }
        session.startDataTask(with: request, convertFromSnakeCase: false, completionHandler: languageCompletion)
    }

    func getAvailableLanguages<L>(completion: @escaping (Result<[L]>) -> Void) where L: LanguageModel {
        let url = baseURLv2 + "content/localize/mobile/languages"
        let request = session.request(url, method: .get, parameters: nil, headers: defaultHeaders)
        let languagesCompletion: (Result<DataModel<[DefaultLanguage]>>) -> Void = { (response) in
            switch response {
            case .success(let data):
                let model = data.model
                let result: Result = .success(model)
                completion(result as! Result<[L]>)
            case .failure:
                let model: [DefaultLanguage] = []
                let result: Result = .success(model)
                completion(result as! Result<[L]>)
            }
        }
        session.startDataTask(with: request, convertFromSnakeCase: false, completionHandler: languagesCompletion)
    }
}
// MARK: - LocalizationContextRepository
extension ConnectionManager {
    func fetchPreferredLanguages() -> [String] {
        return Locale.preferredLanguages
    }

    func getLocalizationBundles() -> [Bundle] {
        return Bundle.allBundles
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return Locale.preferredLanguages.first
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
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
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
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func fetchLanguages(completion: @escaping Completion<[DefaultLanguage]>) {
        let url = baseURLv1 + "geographic/languages"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {
        let url = baseURLv1 + "geographic/time_zones"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        let url = baseURLv1 + "geographic/time_zones/by_lat_lng"
        let parameters: [String: Any] = ["lat_lng": "\(String(lat)),\(String(lng))"]
        let request = session.request(url, parameters: parameters, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        let url = baseURLv1 + "geographic/ip-address"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        let url = baseURLv1 + "geographic/countries"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }
}
// MARK: - ValidationRepository
extension ConnectionManager {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>) {
        let parameters: [String: Any] = ["email": email]
        let url = baseURLv1 + "validator/email"
        let request = session.request(url, parameters: parameters, headers: defaultHeaders)
        session.startDataTask(with: request, convertFromSnakeCase: true, completionHandler: completion)
    }
}
// MARK: - ContentRepository
extension ConnectionManager {
    func fetchStaticResponse<T: Codable>(_ slug: String, completion: @escaping Completion<T>) {
        let url = baseURLv1 + "content/responses/\(slug)"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }
}
// MARK: - ColletionRepository
extension ConnectionManager {
    func fetchCollection<T: Codable>(_ id: Int, completion: @escaping ((Result<T>) -> Void)) {
        let url = baseURLv1 + "content/collections/\(id)"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }
}

// MARK: - ProposalsRepository
extension ConnectionManager {
    func storeProposal(section: String, key: String, value: String, locale: String, completion: @escaping Completion<Proposal>) {
        let params: [String: String] = [
            "section": section,
            "key": key,
            "value": value,
            "platform": "mobile",
            "guid": Configuration.guid,
            "locale": locale
        ]

        var headers = defaultHeaders
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["N-Meta"] = configuration.nmeta.current

        let url = baseURLv2 + "content/localize/proposals"

        let request = session.request(url, method: .post, parameters: params, headers: headers)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func fetchProposals(completion: @escaping Completion<[Proposal]>) {
        let url = baseURLv2 + "content/localize/proposals?guid=\(Configuration.guid)"
        let request = session.request(url, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }

    func deleteProposal(_ proposal: Proposal, completion: @escaping (Result<ProposalDeletion>) -> Void) {
        let url = baseURLv2 + "content/localize/proposals/\(proposal.id)?guid=\(Configuration.guid)"
        let request = session.request(url, method: .delete, parameters: nil, headers: defaultHeaders)
        session.startDataTask(with: request, wrapperType: DataModel.self, convertFromSnakeCase: true, completionHandler: completion)
    }
}

// MARK: - FeedbackRepository
extension ConnectionManager {
    private func getPlatform() -> String {
        #if os(iOS) || os(tvOS)
        switch UIDevice.current.systemName.lowercased() {
        case "ios": return "ios"
        default: return "unknown"
        }
        #elseif os(macOS)
        return ProcessInfo.processInfo.operatingSystemVersionString.lowercased()
        #elseif os(watchOS)
        return WKInterfaceDevice.current().systemName.lowercased()
        #endif
    }
    
    private func modelType() -> String {
        #if os(iOS) || os(tvOS)
        return UIDevice.current.modelType.rawValue
        #elseif os(macOS)
        return "unknown"
        #elseif os(watchOS)
        return WKInterfaceDevice.current().model
        #endif
    }
    
    private func systemVersion() -> String {
        #if os(iOS) || os(tvOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        return "unknown"
        #elseif os(watchOS)
        return WKInterfaceDevice.current().systemVersion
        #endif
    }

    func provideFeedback(_ feedback: Feedback, completion: @escaping Completion<Void>) {
        let boundary = UUID().uuidString

        var urlRequest = URLRequest(url: URL(string: baseURLv2 + "ugc/feedbacks")!)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let builder = MultipartBuilder(boundary: boundary)
            .append(name: "type", value: feedback.type.rawValue)
            .append(name: "platform", value: getPlatform())
            .append(name: "os", value: systemVersion())
            .append(name: "device", value: modelType())
            .append(name: "app_version", value: feedback.appVersion)
            .append(name: "name", value: feedback.name)
            .append(name: "email", value: feedback.email)
            .append(name: "message", value: feedback.message)
            
        #if canImport(UIKit)
        builder.append(name: "image", image: feedback.image, jpegQuality: 0.7)
        #endif

        session.uploadTask(with: urlRequest, from: builder.build(), completionHandler: { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }).resume()
    }
}
