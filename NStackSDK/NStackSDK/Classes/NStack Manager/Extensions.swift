//
//  Extensions.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 12/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit
import Cashier

extension UIApplication {

    class func safeSharedApplication() -> UIApplication? {
        guard UIApplication.responds(to: NSSelectorFromString("sharedApplication")),
            let unmanagedSharedApplication = UIApplication.perform(NSSelectorFromString("sharedApplication")) else {
            return nil
        }

        return unmanagedSharedApplication.takeRetainedValue() as? UIApplication
    }

    func safeOpenURL(_ url: URL) -> Bool {
        guard self.canOpenURL(url) else { return false }

        guard let returnVal = self.perform(NSSelectorFromString("openURL:"), with: url) else {
            return false
        }

        let value = returnVal.takeRetainedValue() as? NSNumber
        return value?.boolValue ?? false
    }
}

extension NStack {
    internal static var persistentStore: NOPersistentStore {
        return NOPersistentStore.cache(withId: NStackConstants.persistentStoreID)
    }

    internal func print(_ items: Any...) {
        guard configured else { return }
        if configuration.verboseMode {
            Swift.print(items)
        }
    }
}
