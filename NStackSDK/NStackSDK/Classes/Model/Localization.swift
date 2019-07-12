//
//  Localization.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 27/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import TranslationManager

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
