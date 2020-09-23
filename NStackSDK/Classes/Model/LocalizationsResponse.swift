//
//  LocalizationsResponse.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
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

public struct LocalizationsResponse: Codable {
    let localization: [String: Any]
    let language: DefaultLanguage?

    enum CodingKeys: String, CodingKey {
        case translations = "data"
        case languageData = "meta"
    }

    enum LanguageCodingKeys: String, CodingKey {
        case language
    }

    init() {
        self.localization = [:]
        self.language = nil
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        localization = try values.decodeIfPresent([String: Any].self, forKey: .translations) ?? [:]

        let languageData = try values.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .languageData)
        language = try languageData.decodeIfPresent(DefaultLanguage.self, forKey: .language)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(localization, forKey: .translations)

        var languageData = container.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .languageData)
        try languageData.encode(language, forKey: .language)
    }
}
