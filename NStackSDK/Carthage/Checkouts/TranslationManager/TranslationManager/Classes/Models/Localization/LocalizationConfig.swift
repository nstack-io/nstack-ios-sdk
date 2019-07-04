//
//  Localization.swift
//  TranslationManager
//
//  Created by Andrew Lloyd on 19/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public struct LocalizationConfig: LocalizationModel {

    public var lastUpdatedAt = Date()
    public var shouldUpdate: Bool = false
    public var localeIdentifier: String
    public var url: String

    public init(lastUpdatedAt: Date = Date(),
                localeIdentifier: String,
                shouldUpdate: Bool = false,
                url: String
                ) {
        self.lastUpdatedAt = lastUpdatedAt
        self.localeIdentifier = localeIdentifier
        self.shouldUpdate = shouldUpdate
        self.url = url
    }
}
