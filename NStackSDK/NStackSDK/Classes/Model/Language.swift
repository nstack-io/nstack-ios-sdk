//
//  Language.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

public struct Language: Codable {
    public let id: Int
    public let name: String
    public let locale: String
    public let direction: String
    public let acceptLanguage: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, locale, direction
        case acceptLanguage = "Accept-Language"
    }
}
