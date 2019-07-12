//
//  Translatable.swift
//  NStack
//
//  Created by Chris Combs on 08/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import TranslationManager

public struct Localizable: LocalizableModel {
    public subscript(key: String) -> LocalizableSection? {
        return nil
    }
}
