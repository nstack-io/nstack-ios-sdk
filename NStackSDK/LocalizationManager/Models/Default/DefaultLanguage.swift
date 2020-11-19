//
//  DefaultLanguage.swift
//  LocalizationManager
//
//  Created by Dominik Hádl on 03/09/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public struct DefaultLanguage: LanguageModel {
    public let id: Int
    public let name: String
    public let direction: String
    public let locale: Locale
    public let isDefault: Bool
    public let isBestFit: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, direction, locale
        case isDefault = "is_default"
        case isBestFit = "is_best_fit"
    }

    public init(id: Int, name: String, direction: String, locale: Locale, isDefault: Bool, isBestFit: Bool) {
        self.id = id
        self.name = name
        self.direction = direction
        self.locale = locale
        self.isDefault = isDefault
        self.isBestFit = isBestFit
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        direction = try values.decode(String.self, forKey: .direction)
        locale = Locale(identifier: try values.decode(String.self, forKey: .locale))
        isDefault = try values.decode(Bool.self, forKey: .isDefault)
        isBestFit = try values.decode(Bool.self, forKey: .isBestFit)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(direction, forKey: .direction)
        try container.encode(locale.identifier, forKey: .locale)
        try container.encode(isDefault, forKey: .isDefault)
        try container.encode(isBestFit, forKey: .isBestFit)
    }
}
