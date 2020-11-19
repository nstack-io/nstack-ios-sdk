//
//  LanguageModel.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

/// A protocol that defines the basic properties a Language model should have, to be usable
/// with LocalizationManager. You will need to create an object that implements this protocol
/// and then provide the type of that object to the LocalizationManager when instantiating.
public protocol LanguageModel: Codable {

    /// The locale of the language, see Apple's documentation on Locale.
    var locale: Locale { get }

    /// If this language is the default one to be used.
    var isDefault: Bool { get }

    /// True if this language fits best the device's/user's preferred languages.
    var isBestFit: Bool { get }
}
