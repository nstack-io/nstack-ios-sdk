//
//  TranslatableManagerDelegate.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public protocol LocalizationManagerDelegate: class {
    func localizationManager(languageUpdated: LanguageModel?)
}
