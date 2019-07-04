//
//  Localization.swift
//  TranslationManagerTests
//
//  Created by Dominik Hádl on 21/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation
import TranslationManager

struct Localization: LocalizableModel {
    var defaultSection: DefaultSection = DefaultSection()
    var other: Other = Other()

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultSection = try container.decodeIfPresent(DefaultSection.self, forKey: .defaultSection) ?? defaultSection
        other = try container.decodeIfPresent(Other.self, forKey: .other) ?? other
    }

    enum CodingKeys: String, CodingKey {
        case other
        case defaultSection = "default"
    }

    public subscript(key: String) -> LocalizableSection? {
        switch key {
        case CodingKeys.other.stringValue: return other
        case CodingKeys.defaultSection.stringValue: return defaultSection
        default: return nil
        }
    }

    struct DefaultSection: LocalizableSection {
        var successKey: String = ""

        init() { }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            successKey = try container.decodeIfPresent(String.self, forKey: .successKey) ?? "__successKey"
        }

        subscript(key: String) -> String? {
            switch key {
            case CodingKeys.successKey.stringValue: return successKey
            default: return nil
            }
        }
    }

    struct Other: LocalizableSection {
        var otherKey: String = ""

        init() { }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            otherKey = try container.decodeIfPresent(String.self, forKey: .otherKey) ?? "__otherKey"
        }

        subscript(key: String) -> String? {
            switch key {
            case CodingKeys.otherKey.stringValue: return otherKey
            default: return nil
            }
        }
    }
}
