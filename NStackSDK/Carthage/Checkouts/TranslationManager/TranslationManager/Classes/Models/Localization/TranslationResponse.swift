//
//  TranslationResponse.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public struct TranslationResponse<L: LanguageModel>: Codable {
    public internal(set) var translations: [String: Any]
    public let meta: TranslationMeta<L>?

    enum CodingKeys: String, CodingKey {
        case translations = "data"
        case meta
    }

    enum LanguageCodingKeys: String, CodingKey {
        case language
    }

    public init(translations: [String: Any] = [:], meta: TranslationMeta<L>? = nil) {
        self.translations = translations
        self.meta = meta
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        translations = try values.decodeIfPresent([String: Any].self, forKey: .translations) ?? [:]

        let metaData = try decoder.container(keyedBy: CodingKeys.self)
        meta = try metaData.decodeIfPresent(TranslationMeta<L>.self, forKey: .meta)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(translations, forKey: .translations)
        try container.encode(meta, forKey: .meta)
    }
}
