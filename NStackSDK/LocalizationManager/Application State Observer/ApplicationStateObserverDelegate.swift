//
//  ApplicationStateObserverDelegate.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 19/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

/// A delegate protocol for application state observer which you should implement if you
/// want to listen to application state changes.
internal protocol ApplicationStateObserverDelegate: class {

    /// A function called whenever an application state changes.
    ///
    /// - Parameter state: The new application state.
    func applicationStateHasChanged(_ state: ApplicationState)
}
