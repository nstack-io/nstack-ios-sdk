//
//  AppOpenMockRepository.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 03/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import LocalizationManager
#elseif os(tvOS)
import LocalizationManager_tvOS
#elseif os(watchOS)
import LocalizationManager_watchOS
#elseif os(macOS)
import LocalizationManager_macOS
#endif

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

    func getLocalizationConfig<C>(acceptLanguage: String, lastUpdated: Date?, completion: @escaping (Result<[C]>) -> Void) where C: LocalizationModel {

    }

    func getLocalizations<L>(localization: LocalizationModel, acceptLanguage: String, completion: @escaping (Result<LocalizationResponse<L>>) -> Void) where L: LanguageModel {
        let localizationsResponse: LocalizationResponse<Language>? = LocalizationResponse(localizations: [
            "default": ["successKey": "SuccessUpdated"],
            "otherSection": ["anotherKey": "HeresAValue"]
            ], meta: LocalizationMeta(language: Language(id: 1, name: "English",
                                                        direction: "LRM", acceptLanguage: "en-GB",
                                                        isDefault: true, isBestFit: true)))

        let result: Result = .success(localizationsResponse!)
        completion(result as! Result<LocalizationResponse<L>>)
    }

    func getAvailableLanguages<L>(completion: @escaping (Result<[L]>) -> Void) where L: LanguageModel {

    }

    func fetchUpdates(oldVersion: String, currentVersion: String, completion: @escaping Completion<Update>) {

    }

    func fetchContinents(completion: @escaping Completion<[Continent]>) {

    }

    func fetchCountries(completion: @escaping Completion<[Country]>) {
        let countryArray = [Country(id: 1,
                                               name: "",
                                               code: "",
                                               codeIso: "", native: "", phone: 1, continent: "",
                                               capital: "", capitalLat: 1.0, capitalLng: 1.0,
                                               currency: "", currencyName: "", languages: "",
                                               image: nil,
                                               imagePath2: nil,
                                               capitalTimeZone: NStackSDK.Timezone(id: 1,
                                                                                   name: "",
                                                                                   abbreviation: "",
                                                                                   offsetSec: 12,
                                                                                   label: ""))]
        let result: Result = .success(countryArray)
        completion(result)
    }

    func fetchLanguages(completion: @escaping Completion<[Language]>) {

    }

    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {

    }

    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {

    }

    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        let result: Result = .success(IPAddress(ipStart: "_ipStart",
                                                ipEnd: "", country: "", stateProv: "", city: "", lat: "", lng: "", timeZoneOffset: "", timeZoneName: "", ispName: "", connectionType: "", type: "", requestedIp: ""))
        completion(result)
    }

    func validateEmail(_ email: String, completion: @escaping Completion<Validation>) {
        let result: Result = .success(Validation(ok: true))
        completion(result)
    }

    struct Person: Swift.Codable {
        var firstName: String
        var lastName: String
    }

    func fetchStaticResponse<T>(_ slug: String, completion: @escaping ((Result<T>) -> Void)) where T: Decodable, T: Encodable {
        let number: Int = 12
        let result: Result = .success(number)
        completion(result as! Result<T>)
    }

    func fetchCollection<T>(_ id: Int, completion: @escaping ((Result<T>) -> Void)) where T: Decodable, T: Encodable {
        let number: Int = 12
        let result: Result = .success(number)
        completion(result as! Result<T>)
    }

    func markWhatsNewAsSeen(_ id: Int) {

    }

    func markMessageAsRead(_ id: Int) {

    }

    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {

    }

    func storeProposal(section: String, key: String, value: String, locale: String, completion: @escaping Completion<Proposal>) {

    }

    func fetchProposals(completion: @escaping Completion<[Proposal]>) {

    }

    func deleteProposal(_ proposal: Proposal, completion: @escaping (Result<ProposalDeletion>) -> Void) {

    }
}

extension MockConnectionManager {
    func postAppOpen(oldVersion: String, currentVersion: String, acceptLanguage: String?, completion: @escaping Completion<AppOpenResponse>) {
        let lang = Language(id: 56, name: "English", direction: "LRM", acceptLanguage: "en-GB", isDefault: true, isBestFit: true)
        let data = AppOpenData(count: 58,
                               message: nil,
                               update: nil,
                               rateReminder: nil,
                               localize: [
                                Localization(id: 56, url: "locazlize.56.url", lastUpdatedAt: "2019-06-21T14:10:29+00:00", shouldUpdate: true, language: lang)
                                ],
                               platform: "ios",
                               createdAt: "2019-06-21T14:10:29+00:00",
                               lastUpdated: "2019-06-21T14:10:29+00:00")

        let response = AppOpenResponse(data: data, languageData: LanguageData(acceptLanguage: "da-DK"))
        completion(.success(response))
    }
}
