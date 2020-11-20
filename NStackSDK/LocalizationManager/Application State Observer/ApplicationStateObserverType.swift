//
//  ApplicationStateObserverType.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 19/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

/// A type of class that can observe application state.
internal protocol ApplicationStateObserverType: class {
    var delegate: ApplicationStateObserverDelegate? { get set }
    func startObserving()
    func stopObserving()
}
