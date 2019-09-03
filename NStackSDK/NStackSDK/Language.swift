//
//  Language.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 02/09/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import LocalizationManager

public struct Language: LanguageModel {
    public let id: Int
    public let name: String

    public let direction: String
    public let acceptLanguage: String
    public let isDefault: Bool
    public let isBestFit: Bool

    public var locale: Locale {
        return Locale(identifier: acceptLanguage)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, direction, isDefault, isBestFit
        case acceptLanguage = "locale"
    }

    public init(id: Int,
                name: String,
                direction: String,
                acceptLanguage: String,
                isDefault: Bool,
                isBestFit: Bool) {
        self.id = id
        self.name = name
        self.direction = direction
        self.acceptLanguage = acceptLanguage
        self.isDefault = isDefault
        self.isBestFit = isBestFit
    }
}
