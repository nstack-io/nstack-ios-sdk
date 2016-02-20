//
//  RateReminder.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable

struct RateReminder {
    var id          = 0
    var title       = ""
    var body        = ""
    var rateBtn     = "" //<-yesBtn
    var laterBtn    = ""
    var neverBtn    = "" //<-noBtn
    var link:NSURL?
}

extension RateReminder:Serializable {
    init(dictionary: NSDictionary?) {
        id       = self.mapped(dictionary, key: "id") ?? id
        title    = self.mapped(dictionary, key: "title") ?? title
        body     = self.mapped(dictionary, key: "body") ?? body
        rateBtn  = self.mapped(dictionary, key: "yesBtn") ?? rateBtn
        laterBtn = self.mapped(dictionary, key: "later_btn") ?? laterBtn
        neverBtn = self.mapped(dictionary, key: "noBtn") ?? neverBtn
        link     = self.mapped(dictionary, key: "link")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["id"]        = id
        dict["title"]     = title
        dict["body"]      = body
        dict["yesBtn"]    = rateBtn
        dict["later_btn"] = laterBtn
        dict["noBtn"]     = neverBtn
        dict["link"]      = link
        return dict
    }
}