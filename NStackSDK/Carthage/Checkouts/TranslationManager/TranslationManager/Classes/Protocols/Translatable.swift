//
//  Translatable.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public protocol Translatable: Codable {
    subscript(key: String) -> TranslatableSection? { get }
}

public protocol TranslatableSection: Codable {
    subscript(key: String) -> String? { get }
}
