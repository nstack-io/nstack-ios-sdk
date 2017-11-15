//
//  Repository.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Alamofire

typealias Completion<T> = ((DataResponse<T>) -> Void)

// MARK: - App Open -

protocol AppOpenRepository {
    func postAppOpen(oldVersion: String, currentVersion: String, acceptLanguage: String?,
                     completion: @escaping Completion<Any>)
}

// MARK: - Updates -

protocol UpdatesRepository {
    func fetchUpdates(oldVersion: String, currentVersion: String,
                      completion: @escaping Completion<Update>)
}

// MARK: - Translations -

protocol TranslationsRepository {
    func fetchTranslations(acceptLanguage: String, completion: @escaping Completion<TranslationsResponse>)
    func fetchCurrentLanguage(acceptLanguage: String, completion: @escaping Completion<Language>)
    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>)
    func fetchPreferredLanguages() -> [String]
    func fetchBundles() -> [Bundle]
}

// MARK: - Geography -

protocol GeographyRepository {
    func fetchContinents(completion: @escaping Completion<[Continent]>)
    func fetchCountries(completion: @escaping Completion<[Country]>)
    func fetchLanguages(completion: @escaping Completion<[Language]>)
    func fetchTimeZones(completion: @escaping Completion<[Timezone]>)
    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>)
    func fetchIPDetails(completion: @escaping Completion<IPAddress>)
}

// MARK: - Validation -

protocol ValidationRepository {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>)
}

// MARK: - Content -

protocol ContentRepository {
    func fetchContent(_ id: Int, completion:  @escaping Completion<Any>)
    func fetchContent(_ slug: String, completion: @escaping Completion<Any>)
}

// MARK: - Versions -

protocol VersionsRepository {
    func markWhatsNewAsSeen(_ id: Int)
    func markMessageAsRead(_ id: String)

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult)
    #endif
}
