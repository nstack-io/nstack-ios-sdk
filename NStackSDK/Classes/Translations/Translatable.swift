//
//  Translatable.swift
//  NStack
//
//  Created by Chris Combs on 08/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif

//import TranslationManager

public class Localizable: LocalizableModel {
    public override subscript(key: String) -> LocalizableSection? {
//        switch key {
//        case CodingKeys.oneMoreSection.stringValue: return oneMoreSection
//        case CodingKeys.otherSection.stringValue: return otherSection
//        case CodingKeys.defaultSection.stringValue: return defaultSection
//        default: return nil
//        }
        print("DEFAULT IMPL: ABOUT TO RETURN NIL FROM NStackSDK.Translatable")
        return nil
    }

    /*
    public var oneMoreSection = OneMoreSection()
    public var otherSection = OtherSection()
    public var defaultSection = DefaultSection()

    enum CodingKeys: String, CodingKey {
        case oneMoreSection
        case otherSection
        case defaultSection = "default"
    }

    public init() { }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        oneMoreSection = try container.decodeIfPresent(OneMoreSection.self, forKey: .oneMoreSection) ?? oneMoreSection
        otherSection = try container.decodeIfPresent(OtherSection.self, forKey: .otherSection) ?? otherSection
        defaultSection = try container.decodeIfPresent(DefaultSection.self, forKey: .defaultSection) ?? defaultSection
    }
    public subscript(key: String) -> LocalizableSection? {
        switch key {
        case CodingKeys.oneMoreSection.stringValue: return oneMoreSection
        case CodingKeys.otherSection.stringValue: return otherSection
        case CodingKeys.defaultSection.stringValue: return defaultSection
        default: return nil
        }
    }

    public final class OneMoreSection: LocalizableSection {
        public var test2 = ""
        public var soManyKeys = ""
        public var test1 = ""

        public init() { }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            test2 = try container.decodeIfPresent(String.self, forKey: .test2) ?? "__test2"
            soManyKeys = try container.decodeIfPresent(String.self, forKey: .soManyKeys) ?? "__soManyKeys"
            test1 = try container.decodeIfPresent(String.self, forKey: .test1) ?? "__test1"
        }

        public subscript(key: String) -> String? {
            switch key {
            case CodingKeys.test2.stringValue: return test2
            case CodingKeys.soManyKeys.stringValue: return soManyKeys
            case CodingKeys.test1.stringValue: return test1
            default: return nil
            }
        }
    }

    public final class OtherSection: LocalizableSection {
        public var otherString = ""

        public init() { }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            otherString = try container.decodeIfPresent(String.self, forKey: .otherString) ?? "__otherString"
        }

        public subscript(key: String) -> String? {
            switch key {
            case CodingKeys.otherString.stringValue: return otherString
            default: return nil
            }
        }
    }

    public final class DefaultSection: LocalizableSection {
        public var keyys = ""
        public var successKey = ""

        public init() { }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            keyys = try container.decodeIfPresent(String.self, forKey: .keyys) ?? "__keyys"
            successKey = try container.decodeIfPresent(String.self, forKey: .successKey) ?? "__successKey"
        }

        public subscript(key: String) -> String? {
            switch key {
            case CodingKeys.keyys.stringValue: return keyys
            case CodingKeys.successKey.stringValue: return successKey
            default: return nil
            }
        }
    }
     */
}
