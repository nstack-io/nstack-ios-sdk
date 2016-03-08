//
//  AppOpenResponseWrapper.swift
//  NStack
//
//  Created by Andrew Lloyd on 04/02/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import Serializable

struct AppOpenResponseWrapper {
    var data : AppOpenResponse?
    var meta : LanguageWrapper?
}

extension AppOpenResponseWrapper: Serializable {
    init(dictionary: NSDictionary?) {
        data <== (self, dictionary, "data")
        meta <== (self, dictionary, "meta")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "data") <== data
        (dict, "meta") <== meta
        return dict
    }
}