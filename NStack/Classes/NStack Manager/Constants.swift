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
	
	//MARK: Geography
	internal static let CountriesKey = "CountriesKey"
}


extension UIApplication {

    class func safeSharedApplication() -> UIApplication? {
        guard UIApplication.respondsToSelector(NSSelectorFromString("sharedApplication")) else {
            return nil
        }

        guard let unmanagedSharedApplication = UIApplication.performSelector(NSSelectorFromString("sharedApplication")) else {
            return nil
        }

        return unmanagedSharedApplication.takeRetainedValue() as? UIApplication
    }

    func safeOpenURL(url: NSURL) {
        if self.canOpenURL(url) {
            guard let returnVal = self.performSelector(NSSelectorFromString("openURL:"), withObject: url) else {
                return
            }
            return
        }
        return
    }
}
