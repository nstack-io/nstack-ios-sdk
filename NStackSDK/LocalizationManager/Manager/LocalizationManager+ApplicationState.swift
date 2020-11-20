//
//  LocalizationManager+ApplicationState.swift
//  LocalizationManager
//
//  Created by Dominik Hádl on 30/08/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

// MARK: - ApplicationStateObserverDelegate

extension LocalizationManager: ApplicationStateObserverDelegate {
    func applicationStateHasChanged(_ state: ApplicationState) {
        switch state {
        case .foreground:
            switch updateMode {
            case .automatic:
                // Update localizations when we go to foreground and update mode is automatic
                updateLocalizations()

            case .manual:
                // Don't do anything on manual update mode
                break
            }

        case .background:
            // Do nothing when we go to background
            break
        }
    }
}
