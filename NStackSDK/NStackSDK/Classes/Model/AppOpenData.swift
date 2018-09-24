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

    let translate: NSDictionary?
    let deviceMapping: [String: String]

    let createdAt: Date
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case count, message, update, rateReminder, translate
        case deviceMapping = "ios_devices"
        case createdAt, lastUpdated
    }
}
