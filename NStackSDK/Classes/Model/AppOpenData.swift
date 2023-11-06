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


public struct AppOpenData: Codable {
    public let count: Int?

    public let message: Message?
    public let update: Update?
    public let rateReminder: RateReminder?

    public let localize: [LocalizationConfig]?
    public let platform: String

    public let createdAt: String
    public let lastUpdated: String?

    public enum CodingKeys: String, CodingKey {
        case count, message, update, localize, platform
        case lastUpdated = "last_updated"
        case createdAt = "created_at"
        case rateReminder = "rate_reminder"
    }
}
