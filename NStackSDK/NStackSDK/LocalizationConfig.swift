//
//  LocalizationConfig.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 02/09/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
import LocalizationManager
#elseif os(tvOS)
import LocalizationManager_tvOS
#elseif os(watchOS)
import LocalizationManager_watchOS
#elseif os(macOS)
import LocalizationManager_macOS
#endif

public struct LocalizationConfig: LocalizationDescriptor {

    public var language: DefaultLanguage
    public var lastUpdatedAt = Date()
    public var shouldUpdate: Bool = false
    public var localeIdentifier: String
    public var url: String

    enum CodingKeys: String, CodingKey {
        case language, url
        case lastUpdatedAt = "last_updated_at"
        case shouldUpdate = "should_update"
        case localeIdentifier = "locale_identifier"
    }

    public init(
        lastUpdatedAt: Date = Date(),
        localeIdentifier: String,
        shouldUpdate: Bool = false,
        url: String,
        language: DefaultLanguage
        ) {
        self.lastUpdatedAt = lastUpdatedAt
        self.localeIdentifier = localeIdentifier
        self.shouldUpdate = shouldUpdate
        self.url = url
        self.language = language
    }
}
