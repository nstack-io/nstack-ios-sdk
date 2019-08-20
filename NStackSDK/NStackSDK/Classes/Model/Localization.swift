//
//  Localization.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 27/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import TranslationManager
#elseif os(tvOS)
import TranslationManager_tvOS
#elseif os(watchOS)
import TranslationManager_watchOS
#elseif os(macOS)

#endif


public struct Localization: LocalizationModel {

    public var id: Int
    public var url: String
    public var lastUpdatedAt: String
    public var shouldUpdate: Bool
    public var language: Language

    public var localeIdentifier: String {
        return language.acceptLanguage
    }
}
