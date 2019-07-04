//
//  LocalizableModel.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public protocol LocalizableModel: Codable {
    subscript(key: String) -> LocalizableSection? { get }
}

public protocol LocalizableSection: Codable {
    subscript(key: String) -> String? { get }
}
