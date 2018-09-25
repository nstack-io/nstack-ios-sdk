//
//  AppOpenData.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

struct AppOpenData: Codable {
    let count: Int

    let message: Message?
    let update: Update?
    let rateReminder: RateReminder?

    let translate: [String: Any]?
    let deviceMapping: [String: Any]

    let createdAt: Date
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case count, message, update, rateReminder, translate
        case deviceMapping = "ios_devices"
        case createdAt, lastUpdated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decode(Int.self, forKey: .count)
        message = try container.decodeIfPresent(Message.self, forKey: .message)
        update = try container.decodeIfPresent(Update.self, forKey: .update)
        rateReminder = try container.decodeIfPresent(RateReminder.self, forKey: .rateReminder)
        translate = try container.decodeIfPresent([String: Any].self, forKey: .translate)
        deviceMapping = try container.decode([String: Any].self, forKey: .deviceMapping)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(message, forKey: .message)
        try container.encode(update, forKey: .update)
        try container.encode(rateReminder, forKey: .rateReminder)
        try container.encode(translate, forKey: .translate)
        try container.encode(deviceMapping, forKey: .deviceMapping)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
}
