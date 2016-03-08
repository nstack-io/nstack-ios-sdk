//
//  AppOpenResponse.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable

struct AppOpenResponse {
    var count = 0
    var message:Message?
    var update:Update?
    var rateReminder:RateReminder?
    var createdAt:Date = Date()
    var lastUpdated:Date = Date()
    var translate:NSDictionary = [:]
}

extension AppOpenResponse: Serializable {
    init(dictionary: NSDictionary?) {
        count        <== (self, dictionary, "count")
        message      <== (self, dictionary, "message")
        update       <== (self, dictionary, "update")
        rateReminder <== (self, dictionary, "rate_reminder")
        createdAt    <== (self, dictionary, "created_at")
        lastUpdated  <== (self, dictionary, "last_updated")
        translate    <== (self, dictionary, "translate")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "count")         <== count
        (dict, "message")       <== message
        (dict, "update")        <== update
        (dict, "rate_reminder") <== rateReminder
        (dict, "created_at")    <== createdAt
        (dict, "last_updated")  <== lastUpdated
        (dict, "translate")     <== translate
        return dict
    }
}