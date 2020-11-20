//
//  ApplicationState.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 19/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

/// An application state enum used by the `ApplicationStateObserver` for distinguishing between app states.
///
/// - foreground: Foreground means the app is currently active.
/// - background: Background means the app was backgrounded.
internal enum ApplicationState {
    case foreground
    case background
}
