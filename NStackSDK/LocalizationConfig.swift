//
//  LocalizationConfig.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 02/09/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
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

public struct LocalizationConfig: LocalizationDescriptor {

    public var language: DefaultLanguage
    public var lastUpdatedAt: String
    public var shouldUpdate: Bool = false
    public var url: String

    enum CodingKeys: String, CodingKey {
        case language, url
        case lastUpdatedAt = "last_updated_at"
        case shouldUpdate = "should_update"
    }

    public init(
        lastUpdatedAt: String = "",
        shouldUpdate: Bool = false,
        url: String,
        language: DefaultLanguage
        ) {
        self.lastUpdatedAt = lastUpdatedAt
        self.shouldUpdate = shouldUpdate
        self.url = url
        self.language = language
    }
}
