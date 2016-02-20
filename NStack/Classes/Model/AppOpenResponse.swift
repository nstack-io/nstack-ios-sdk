//
//  AppOpenResponse.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable

internal struct AppOpenResponse {
    var count = 0
    var message:Message?
    var update:Update?
    var rateReminder:RateReminder?
    var createdAt:Date = Date()
    var lastUpdated:Date = Date()
    var translate:NSDictionary = [:]
}

extension AppOpenResponse:Serializable {
    init(dictionary: NSDictionary?) {
        count        = self.mapped(dictionary, key: "count") ?? count
        message      = self.mapped(dictionary, key: "message")
        update       = self.mapped(dictionary, key: "update")
        rateReminder = self.mapped(dictionary, key: "rate_reminder")
        createdAt    = self.mapped(dictionary, key: "created_at") ?? createdAt
        lastUpdated  = self.mapped(dictionary, key: "last_updated") ?? lastUpdated
        translate    = self.mapped(dictionary, key: "translate") ?? translate
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["count"]         = count
        dict["message"]       = message?.encodableRepresentation()
        dict["update"]        = update?.encodableRepresentation()
        dict["rate_reminder"] = rateReminder?.encodableRepresentation()
        dict["created_at"]    = createdAt.encodableRepresentation()
        dict["last_updated"]  = lastUpdated.encodableRepresentation()
        dict["translate"]     = translate
        return dict
    }
}