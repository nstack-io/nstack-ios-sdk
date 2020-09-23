//
//  AppOpenData.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif


struct AppOpenData: Codable {
    let count: Int?

    let message: Message?
    let update: Update?
    let rateReminder: RateReminder?

    let localize: [LocalizationConfig]?
    let platform: String

    let createdAt: String
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case count, message, update, localize, platform
        case lastUpdated = "last_updated"
        case createdAt = "created_at"
        case rateReminder = "rate_reminder"
    }
}
