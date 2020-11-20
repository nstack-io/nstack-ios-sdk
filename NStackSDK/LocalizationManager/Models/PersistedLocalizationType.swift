//
//  PersistedLocalizationType.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 14/11/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public enum PersistedLocalizationType: String, Codable {
    /// If all languages are in peristed, typically nested under locale identifier.
    /// For exeample: "ar-AR" : { ... }, "en" : { .. }
    case all

    /// If only a single language is in the persisted file at the root level of the data structure.
    case single
}
