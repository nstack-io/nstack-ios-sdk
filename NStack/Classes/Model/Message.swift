//
//  Message.swift
//  NStack
//
//  Created by Kasper Welner on 21/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable

internal struct Message {
    var id = ""
    var message = ""
    var showSetting = ""
}

extension Message:Serializable {
    init(dictionary: NSDictionary?) {
        id          = self.mapped(dictionary, key: "id") ?? id
        message     = self.mapped(dictionary, key: "message") ?? message
        showSetting = self.mapped(dictionary, key: "show_setting") ?? showSetting
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["id"]           = id
        dict["message"]      = message
        dict["show_setting"] = showSetting
        return dict
    }
}