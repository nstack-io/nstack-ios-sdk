//
//  TranslationsResponse.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import TranslationManager

public struct TranslationsResponse: Codable {
    let translations: [String: Any]
    let language: Language?

    enum CodingKeys: String, CodingKey {
        case translations = "data"
        case languageData = "meta"
    }

    enum LanguageCodingKeys: String, CodingKey {
        case language
    }

    init() {
        self.translations = [:]
        self.language = nil
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        translations = try values.decodeIfPresent([String: Any].self, forKey: .translations) ?? [:]

        let languageData = try values.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .languageData)
        language = try languageData.decodeIfPresent(Language.self, forKey: .language)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(translations, forKey: .translations)

        var languageData = container.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .languageData)
        try languageData.encode(language, forKey: .language)
    }
}
