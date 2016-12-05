//
//  AppOpenResponse.swift
//  NStack
//
//  Created by Andrew Lloyd on 04/02/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import Serpent

// TODO: Fix update struct in app open and adjust fetchUpdates response model

struct AppOpenResponse {
    var data: AppOpenData?
    var languageData: LanguageData? // <-meta
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
