//
//  LocalizationResponse.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public struct LocalizationResponse<L: LanguageModel>: Codable {
    public internal(set) var localization: [String: Any]
    public let meta: LocalizationMeta<L>?

    enum CodingKeys: String, CodingKey {
        case localizations = "data"
        case meta
    }

    enum LanguageCodingKeys: String, CodingKey {
        case language
    }

    public init(localizations: [String: Any] = [:], meta: LocalizationMeta<L>? = nil) {
        self.localization = localizations
        self.meta = meta
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        localization = try values.decodeIfPresent([String: Any].self, forKey: .localizations) ?? [:]

        let metaData = try decoder.container(keyedBy: CodingKeys.self)
        meta = try metaData.decodeIfPresent(LocalizationMeta<L>.self, forKey: .meta)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(localization, forKey: .localizations)
        try container.encode(meta, forKey: .meta)
    }
}
