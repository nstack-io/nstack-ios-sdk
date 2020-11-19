//
//  UpdateMode.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 19/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

/// Decides how should the localizations be updated.
///
/// - automatic: Manages update of localizations automatically.
/// - manual: The manager does no automatic updates, you are responsible for updating the localizations.
public enum UpdateMode {
    case automatic
    case manual
}
