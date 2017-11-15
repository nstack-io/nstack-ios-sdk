//
//  Validation.swift
//  NStackSDK
//
//  Created by Christian Graver on 31/10/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Serpent

struct Validation {
    var ok = false
}

extension Validation: Serializable {
    init(dictionary: NSDictionary?) {
        ok <== (self, dictionary, "ok")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "ok") <== ok
        return dict
    }
}
