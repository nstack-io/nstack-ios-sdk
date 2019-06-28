//
//  Language.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

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
}
