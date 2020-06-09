//
//  AppOpenMockRepository.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 03/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif

class MockConnectionManager: Repository {

    var succeed: Bool = true
    var appOpenData = AppOpenData(count: 58,
                                  message: nil,
                                  update: nil,
                                  rateReminder: nil,
                                  localize: [
                                      LocalizationConfig(lastUpdatedAt: "",
                                                         shouldUpdate: true,
                                                         url: "locazlize.56.url",
                                                         language: DefaultLanguage(id: 56,
                                                                                   name: "English",
                                                                                   direction: "LRM",
                                                                                   locale: Locale(identifier: "en-GB"),
                                                                                   isDefault: true,
                                                                                   isBestFit: true))
                                  ],
                                  platform: "ios",
                                  createdAt: "2019-06-21T14:10:29+00:00",
                                  lastUpdated: "2019-06-21T14:10:29+00:00")

    func getLocalizationDescriptors<D>(acceptLanguage: String, lastUpdated: Date?, completion: @escaping (Swift.Result<[D], Error>) -> Void) where D: LocalizationDescriptor {}

    func getLocalization<L, D>(descriptor: D, acceptLanguage: String, completion: @escaping (Swift.Result<LocalizationResponse<L>, Error>) -> Void) where L: LanguageModel, D: LocalizationDescriptor {
        let language = DefaultLanguage(id: 1, name: "English",
                                       direction: "LRM", locale: Locale(identifier: "en-GB"),
                                       isDefault: true, isBestFit: true)

        let localizationsResponse: LocalizationResponse<DefaultLanguage>? = LocalizationResponse(localizations: [
            "default": ["successKey": "SuccessUpdated"],
            "otherSection": ["anotherKey": "HeresAValue"]
        ], meta: LocalizationMeta(language: language))

        let result: Result = .success(localizationsResponse!)
        completion(result as! Result<LocalizationResponse<L>>)
    }

    func fetchPreferredLanguages() -> [String] {
        return []
    }

    func getLocalizationBundles() -> [Bundle] {
        return []
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return nil
    }

    func getAvailableLanguages<L>(completion: @escaping (Result<[L]>) -> Void) where L: LanguageModel {}

    func fetchUpdates(oldVersion: String, currentVersion: String, completion: @escaping Completion<Update>) {}

    func fetchContinents(completion: @escaping Completion<[Continent]>) {
        let continentArray = [Continent(id: 12, name: "TestContinent", code: "testCode", imageUrl: nil)]
        let result: Result = .success(continentArray)
        completion(result)
    }

    func fetchCountries(completion: @escaping Completion<[Country]>) {
        let countryArray = [
            Country(id: 1,
                    name: "TestCountry",
                    code: "TCY",
                    codeIso: "", native: "", phone: 1, continent: "",
                    capital: "", capitalLat: 1.0, capitalLng: 1.0,
                    currency: "", currencyName: "", languages: "",
                    image: nil,
                    imagePath2: nil,
                    capitalTimeZone: NStackSDK.Timezone(id: 1,
                                                        name: "",
                                                        abbreviation: "",
                                                        offsetSec: 12,
                                                        label: ""))
        ]
        let result: Result = .success(countryArray)
        completion(result)
    }

    func fetchLanguages(completion: @escaping Completion<[DefaultLanguage]>) {
        let languagesArray = [DefaultLanguage(id: 123, name: "TestLanguage", direction: "LRM", locale: Locale(identifier: "en-GB"), isDefault: true, isBestFit: true)]
        let result: Result = .success(languagesArray)
        completion(result)
    }

    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        let timezone = NStackSDK.Timezone(id: 1,
                                          name: "TestTimeZone",
                                          abbreviation: "",
                                          offsetSec: 12,
                                          label: "")
        let result: Result = .success(timezone)
        completion(result)
    }

    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {}

    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        let result: Result = .success(IPAddress(ipStart: "_ipStart",
                                                ipEnd: "",
                                                country: "",
                                                stateProv: "",
                                                city: "",
                                                lat: 0,
                                                lng: 0,
                                                timeZoneOffset: "",
                                                timeZoneName: "",
                                                ispName: "",
                                                connectionType: "",
                                                type: "",
                                                requiredIp: ""))
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

    func markWhatsNewAsSeen(_ id: Int) {}

    func markMessageAsRead(_ id: Int) {}

    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {}

    func storeProposal(section: String, key: String, value: String, locale: String, completion: @escaping Completion<Proposal>) {
        let proposal = Proposal(id: 1, applicationId: 123, key: key, section: section, localeString: locale, value: value)
        if succeed {
            completion(.success(proposal))
        } else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: nil)))
        }
    }

    func fetchProposals(completion: @escaping Completion<[Proposal]>) {}

    func deleteProposal(_ proposal: Proposal, completion: @escaping (Result<ProposalDeletion>) -> Void) {}

    func provideFeedback(_ feedback: Feedback, completion: @escaping Completion<Void>) {}
}

extension MockConnectionManager {
    func postAppOpen(oldVersion: String, currentVersion: String, acceptLanguage: String?, completion: @escaping Completion<AppOpenResponse>) {
        if succeed {
            let response = AppOpenResponse(data: appOpenData, languageData: LanguageData(acceptLanguage: "da-DK"))
            completion(.success(response))
        } else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: nil)))
        }
    }
}
