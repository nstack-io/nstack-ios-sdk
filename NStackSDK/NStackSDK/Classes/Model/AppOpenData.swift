//
//  AppOpenData.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serpent

struct AppOpenData {
    var count = 0

    var message: Message?
    var update: Update?
    var rateReminder: RateReminder?

    var translate: NSDictionary?
    var deviceMapping: [String: String] = [:] // <-ios_devices

    var createdAt = Date()
    var lastUpdated = Date()
}

extension AppOpenData: Serializable {
    init(dictionary: NSDictionary?) {
        count         <== (self, dictionary, "count")
        message       <== (self, dictionary, "message")
        update        <== (self, dictionary, "update")
        rateReminder  <== (self, dictionary, "rate_reminder")
        translate     <== (self, dictionary, "translate")
        deviceMapping <== (self, dictionary, "ios_devices")
        createdAt     <== (self, dictionary, "created_at")
        lastUpdated   <== (self, dictionary, "last_updated")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "count")         <== count
        (dict, "message")       <== message
        (dict, "update")        <== update
        (dict, "rate_reminder") <== rateReminder
        (dict, "translate")     <== translate
        (dict, "ios_devices")   <== deviceMapping
        (dict, "created_at")    <== createdAt
        (dict, "last_updated")  <== lastUpdated
        return dict
    }
}
