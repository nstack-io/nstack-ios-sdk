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

extension AppOpenResponseWrapper:Serializable {
    init(dictionary: NSDictionary?) {
        data = self.mapped(dictionary, key: "data")
        meta = self.mapped(dictionary, key: "meta")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["data"] = data?.encodableRepresentation()
        dict["meta"] = meta?.encodableRepresentation()
        return dict
    }
}