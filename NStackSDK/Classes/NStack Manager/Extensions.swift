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
        guard UIApplication.respondsToSelector(NSSelectorFromString("sharedApplication")),
            let unmanagedSharedApplication = UIApplication.performSelector(NSSelectorFromString("sharedApplication")) else {
            return nil
        }

        return unmanagedSharedApplication.takeRetainedValue() as? UIApplication
    }

    func safeOpenURL(url: NSURL) {
        if self.canOpenURL(url) {
            guard let _ = self.performSelector(NSSelectorFromString("openURL:"), withObject: url) else {
                return
            }
            return
        }
        return
    }
}

extension NStack {
    internal static var persistentStore: NOPersistentStore {
        return NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID)
    }

    internal func print(items: Any...) {
        guard configured else { return }
        if configuration.verboseMode {
            print(items)
        }
    }
}