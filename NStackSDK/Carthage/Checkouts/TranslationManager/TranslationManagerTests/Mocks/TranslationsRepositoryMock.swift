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
    var availableLocalizations: [LocalizationConfig]?
    var availableLanguages: [L]?
    var currentLanguage: Language?
    var currentLocalization: LocalizationConfig?
    var preferredLanguages = ["en"]
    var customBundles: [Bundle]?

    func getLocalizationConfig<C>(acceptLanguage: String,
                               lastUpdated: Date?,
                               completion: @escaping (Result<[C]>) -> Void) where C: LocalizationModel {
        let error = NSError(domain: "", code: 100, userInfo: nil) as Error
        let result: Result = availableLocalizations != nil ? .success(availableLocalizations!) : .failure(error)
        completion(result as! Result<[C]>)
    }

    func getTranslations<L>(localization: LocalizationModel,
                            acceptLanguage: String,
                            completion: @escaping (Result<TranslationResponse<L>>) -> Void) where L: LanguageModel {
        let error = NSError(domain: "", code: 0, userInfo: nil) as Error
        let result: Result = translationsResponse != nil ? .success(translationsResponse!) : .failure(error)
        completion(result as! Result<TranslationResponse<L>>)
    }

    func getTranslations<L>(localization: LocalizationModel,
                            acceptLanguage: String,
                            completion: @escaping (Result<L>) -> Void) where L: LanguageModel {
        let error = NSError(domain: "", code: 0, userInfo: nil) as Error
        //let result: Result = translationsResponse != nil ? .success(translationsResponse!) : .failure(error)
        let result: Result = .success(currentLanguage!)
        completion(result as! Result<L>)
    }

    func getAvailableLanguages<L: LanguageModel>(completion:  @escaping (Result<[L]>) -> Void) {
//        let error = NSError(domain: "", code: 0, userInfo: nil)
//        let result: Result = availableLanguages != nil ? .success(availableLanguages!) : .failure(error)
//        completion(result)
    }
}

extension TranslationsRepositoryMock: LocalizationContextRepository {

    func fetchPreferredLanguages() -> [String] {
        return preferredLanguages
    }

    func getLocalizationBundles() -> [Bundle] {
        return customBundles ?? Bundle.allBundles
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return preferredLanguages.first
    }
}
