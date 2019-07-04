//
//  LocalizationModel.swift
//  TranslationManager
//
//  Created by Andrew Lloyd on 19/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public protocol LocalizationModel: Codable {
    var shouldUpdate: Bool { get }
    var localeIdentifier: String { get }
    var url: String { get }
}
