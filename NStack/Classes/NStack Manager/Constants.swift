//
//  Constants.swift
//  NStack
//
//  Created by Kasper Welner on 02/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit

internal struct NStackConstants {
    internal static let cacheID = "NStack"
    internal static let persistentStoreID = "NStack"
    internal static let lastUpdatedDateKey = "LastUpdated"
    internal static let prevAcceptedLanguageKey = "PrevAcceptedLanguageKey"
}


extension UIApplication {

    class func safeSharedApplication() -> UIApplication? {
        guard UIApplication.responds(to: NSSelectorFromString("sharedApplication")) else {
            return nil
        }

        guard let unmanagedSharedApplication = UIApplication.perform(NSSelectorFromString("sharedApplication")) else {
            return nil
        }

        return unmanagedSharedApplication.takeRetainedValue() as? UIApplication
    }

    func safeOpenURL(_ url: URL) {
        if self.canOpenURL(url) {
            guard let _ = self.perform(NSSelectorFromString("openURL:"), with: url) else {
                return
            }
            return
        }
        return
    }
}
