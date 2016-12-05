//
//  Extensions.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 12/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

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

extension FileManager {
    var documentsDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
