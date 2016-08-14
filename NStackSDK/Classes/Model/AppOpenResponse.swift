//
//  AppOpenResponse.swift
//  NStack
//
//  Created by Andrew Lloyd on 04/02/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import Serializable

struct AppOpenResponse {
    var data : AppOpenData?
    var languageData : LanguageData? // <-meta
}

extension AppOpenResponse: Serializable {
    init(dictionary: NSDictionary?) {
        data         <== (self, dictionary, "data")
        languageData <== (self, dictionary, "meta")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "data") <== data
        (dict, "meta") <== languageData
        return dict
    }
}