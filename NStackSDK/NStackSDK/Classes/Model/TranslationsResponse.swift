//
//  TranslationsResponse.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Serpent

struct TranslationsResponse {
    var translations: NSDictionary? // <-data
    var languageData: LanguageData? // <-meta
}

extension TranslationsResponse: Serializable {
    init(dictionary: NSDictionary?) {
        translations <== (self, dictionary, "data")
        languageData <== (self, dictionary, "meta")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "data") <== translations
        (dict, "meta") <== languageData
        return dict
    }
}
