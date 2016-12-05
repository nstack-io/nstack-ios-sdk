//
//  TranslationsRepositoryMock.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 05/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Alamofire
@testable import NStackSDK

class TranslationsRepositoryMock: TranslationsRepository {
    var translationsResponse: TranslationsResponse?

    func fetchTranslations(acceptLanguage: String, completion: @escaping ((DataResponse<TranslationsResponse>) -> Void)) {
        return DataResponse(request: nil, response: nil, data: nil, result: Result.success(response))
    }

    func fetchAvailableLanguages(completion: @escaping ((DataResponse<[Language]>) -> Void)) {

    }

    func fetchCurrentLanguage(acceptLanguage: String, completion: @escaping ((DataResponse<Language>) -> Void)) {

    }
}
