//
//  TranslationsRepository.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Alamofire

protocol TranslationsRepository {
    func fetchTranslations(_ completion: @escaping ((DataResponse<TranslationsResponse>) -> Void))
    func fetchCurrentLanguage(_ completion:  @escaping((DataResponse<Language>) -> Void))
    func fetchAvailableLanguages(_ completion:  @escaping ((DataResponse<[Language]>) -> Void))
}
