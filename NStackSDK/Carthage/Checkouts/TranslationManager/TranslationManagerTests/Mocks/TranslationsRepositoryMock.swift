//
//  TranslationsRepositoryMock.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 05/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
@testable import TranslationManager

class TranslationsRepositoryMock<L: LanguageModel>: TranslationRepository {

    var translationsResponse: TranslationResponse<Language>?
    var availableLocalizations: [LocalizationModel]?
    var availableLanguages: [L]?
    var currentLanguage: Language?
    var currentLocalization: LocalizationModel?
    var preferredLanguages = ["en"]
    var customBundles: [Bundle]?

    func getLocalizationConfig(acceptLanguage: String,
                               lastUpdated: Date?,
                               completion: @escaping (Result<[LocalizationModel]>) -> Void) {
        let error = NSError(domain: "", code: 100, userInfo: nil) as Error
        let result: Result = availableLocalizations != nil ? .success(availableLocalizations!) : .failure(error)
        completion(result)
    }

    func getTranslations(localization: LocalizationModel,
                         acceptLanguage: String,
                         completion: @escaping (Result<TranslationResponse<Language>>) -> Void) {

        let error = NSError(domain: "", code: 0, userInfo: nil) as Error
        let result: Result = translationsResponse != nil ? .success(translationsResponse!) : .failure(error)
        completion(result)
    }

    func getAvailableLanguages<L: LanguageModel>(completion:  @escaping (Result<[L]>) -> Void) {
//        let error = NSError(domain: "", code: 0, userInfo: nil)
//        let result: Result = availableLanguages != nil ? .success(availableLanguages!) : .failure(error)
//        completion(result)
    }

    func fetchPreferredLanguages() -> [String] {
        return preferredLanguages
    }

    func fetchBundles() -> [Bundle] {
        return customBundles ?? Bundle.allBundles
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return preferredLanguages.first
    }
}
