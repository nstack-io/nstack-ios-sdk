//
//  UIApplication+SafeExtensions.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 11/02/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

#if !os(watchOS)

extension UIApplication {
    class func safeSharedApplication() -> UIApplication? {
        guard UIApplication.responds(to: NSSelectorFromString("sharedApplication")),
            let unmanagedSharedApplication = UIApplication.perform(NSSelectorFromString("sharedApplication")) else {
                return nil
        }

        return unmanagedSharedApplication.takeRetainedValue() as? UIApplication
    }

    func safeOpenURL(_ url: URL) {
        guard self.canOpenURL(url) else { return }

        guard self.perform(NSSelectorFromString("openURL:"), with: url) != nil else {
            return
        }
    }
}

#endif
