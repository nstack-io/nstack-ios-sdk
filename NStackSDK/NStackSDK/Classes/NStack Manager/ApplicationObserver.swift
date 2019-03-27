//
//  ApplicationObserver.swift
//  NStack
//
//  Created by Kasper Welner on 25/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import Foundation

enum ApplicationAction {
    case didBecomeActive
}

class ApplicationObserver {

    typealias ActionHandler = ((ApplicationAction) -> Void)

    /// This closure is executed every time there is an app action happening.
    let actionHandler: ActionHandler

    private var first = true

    // MARK: - Lifecycle -

    init(handler: @escaping ActionHandler) {
        self.actionHandler = handler

        let selector = #selector(applicationDidBecomeActive)
        #if os(macOS)
        let name = NSApplication.didBecomeActiveNotification
        #elseif os(watchOS)
            let name = NSNotification.Name(rawValue: "UIApplicationDidEnterBackgroundNotification")
        #else
            let name = UIApplication.didBecomeActiveNotification
        #endif
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions -

    @objc func applicationDidBecomeActive(_ notification: Notification) {
        guard !first else {
            first = false
            return
        }

        actionHandler(.didBecomeActive)
    }
}
