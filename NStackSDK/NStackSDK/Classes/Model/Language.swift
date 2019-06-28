//
//  Language.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import TranslationManager

public struct Language: LanguageModel {
    public var locale: Locale {
        return Locale(identifier: acceptLanguage)
    }
    
    public let id: Int
    public let name: String
    public let direction: String
    public let acceptLanguage: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, direction
        case acceptLanguage = "locale"
    }
}
