//
//  Message.swift
//  NStack
//
//  Created by Kasper Welner on 21/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serpent

internal struct Message {
    var id = ""
    var message = ""
    var showSetting = ""
}

extension Message: Serializable {
    init(dictionary: NSDictionary?) {
        id          <== (self, dictionary, "id")
        message     <== (self, dictionary, "message")
        showSetting <== (self, dictionary, "show_setting")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")           <== id
        (dict, "message")      <== message
        (dict, "show_setting") <== showSetting
        return dict
    }
}
