//
//  LocalizationDescriptor.swift
//  LocalizationManager
//
//  Created by Andrew Lloyd on 19/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public protocol LocalizationDescriptor: Codable {
    associatedtype LanguageType: LanguageModel

    var shouldUpdate: Bool { get }
    var url: String { get }
    var language: LanguageType { get }
}
