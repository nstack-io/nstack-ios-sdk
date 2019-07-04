//
//  AppOpenMockRepository.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 03/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import TranslationManager

class MockConnectionManager: Repository {
    func fetchPreferredLanguages() -> [String] {
        return []
    }

    func getLocalizationBundles() -> [Bundle] {
        return []
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return nil
    }

    func getLocalizationConfig(acceptLanguage: String, lastUpdated: Date?, completion: @escaping (Result<[LocalizationModel]>) -> Void) {

    }

    func getTranslations<L>(localization: LocalizationModel, acceptLanguage: String, completion: @escaping (Result<TranslationResponse<L>>) -> Void) where L : LanguageModel {

    }

    func getAvailableLanguages<L>(completion: @escaping (Result<[L]>) -> Void) where L : LanguageModel {

    }

    func fetchUpdates(oldVersion: String, currentVersion: String, completion: @escaping Completion<Update>) {

    }

    func fetchContinents(completion: @escaping Completion<[Continent]>) {

    }

    func fetchCountries(completion: @escaping Completion<[Country]>) {

    }

    func fetchLanguages(completion: @escaping Completion<[Language]>) {

    }

    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {

    }

    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {

    }

    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {

    }

    func validateEmail(_ email: String, completion: @escaping Completion<Validation>) {

    }

    func fetchStaticResponse<T>(_ slug: String, completion: @escaping ((Result<T>) -> Void)) where T : Decodable, T : Encodable {

    }

    func fetchCollection<T>(_ id: Int, completion: @escaping ((Result<T>) -> Void)) where T : Decodable, T : Encodable {

    }

    func markWhatsNewAsSeen(_ id: Int) {

    }

    func markMessageAsRead(_ id: String) {

    }

    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {

    }
}

extension MockConnectionManager {
    func postAppOpen(oldVersion: String, currentVersion: String, acceptLanguage: String?, completion: @escaping Completion<AppOpenResponse>) {
        let lang = Language(id: 56, name: "English", direction: "LRM", acceptLanguage: "en_EN", isDefault: true, isBestFit: false)
        let data = AppOpenData(count: 58,
                               message: nil,
                               update: nil,
                               rateReminder: nil,
                               localize: [
        Localization(id: 56, url: "locazlize.56.url", lastUpdatedAt: "2019-06-21T14:10:29+00:00", shouldUpdate: true, language: lang),
        Localization(id: 56, url: "locazlize.56.url", lastUpdatedAt: "2019-06-21T14:10:29+00:00", shouldUpdate: true, language: lang)],
                               platform: "ios",
                               createdAt: "2019-06-21T14:10:29+00:00",
                               lastUpdated: "2019-06-21T14:10:29+00:00")


        let response = AppOpenResponse(data: data, languageData: LanguageData(acceptLanguage: "da-DK"))
        completion(.success(response))
    }
}
