//
//  Store.swift
//  LocalizationManager
//
//  Created by Dominik Hádl on 27/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

protocol Store {
    associatedtype LanguageType: LanguageModel
    func data(for language: LanguageType) throws -> Data
    func save(_ data: Data, for language: LanguageType) throws
}
