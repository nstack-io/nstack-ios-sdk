//
//  ApplicationStateObserver.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 19/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// An application state observe class that listens to different application states (fx. foreground/background).
@objc internal class ApplicationStateObserver: NSObject, ApplicationStateObserverType {

    /// Notification center that we will subscribed to for app state notifications.
    private let notificationCenter: NotificationCenter

    /// Delegate that will be called on state changes.
    internal weak var delegate: ApplicationStateObserverDelegate?

    /// The current application state.
    internal private(set) var state: ApplicationState {
        didSet {
            delegate?.applicationStateHasChanged(state)
        }
    }

    /// Creates the application state observer with a delegate and optionally a custom notification center.
    ///
    /// - Parameters:
    ///   - delegate: The delegate that should get state change callbacks.
    ///   - notificationCenter: Notification center that should be used for listening to app state changes.
    internal init(delegate: ApplicationStateObserverDelegate,
                  notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        self.delegate = delegate

        // Start in foreground state
        // (won't call didSet as it's called from init)
        state = .foreground
    }

    /// Starts observing application state
    internal func startObserving() {
        #if os(iOS) || os(tvOS)
        notificationCenter.addObserver(self, selector: #selector(observeStateChange(_:)),
                                       name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(observeStateChange(_:)),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        #elseif os(watchOS)
        notificationCenter.addObserver(self, selector: #selector(observeStateChange(_:)),
                                       name: Notification.Name.NSExtensionHostDidBecomeActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(observeStateChange(_:)),
                                       name: Notification.Name.NSExtensionHostDidEnterBackground, object: nil)
        #endif
    }

    /// Stops observing application state
    internal func stopObserving() {
        notificationCenter.removeObserver(self)
    }

    /// Observe the change in application state based on UIApplication notifications
    ///
    /// - Parameter notification: The notification that triggered state change.
    @objc private func observeStateChange(_ notification: Notification) {
        #if os(iOS) || os(tvOS)
        observeStateChangeIOS(notification)
        #elseif os(watchOS)
        observeStateChangeWatchOS(notification)
        #endif
    }

    private func observeStateChangeIOS(_ notification: Notification) {
        #if os(iOS) || os(tvOS)
        switch notification.name {
        case UIApplication.didBecomeActiveNotification:
            state = .foreground

        case UIApplication.didEnterBackgroundNotification:
            state = .background

        default:
            return
        }
        #endif
    }

    private func observeStateChangeWatchOS(_ notification: Notification) {
        #if os(watchOS)
        switch notification.name {
        case .NSExtensionHostDidBecomeActive:
            state = .foreground

        case .NSExtensionHostDidEnterBackground:
            state = .background

        default:
            return
        }
        #endif
    }
}
