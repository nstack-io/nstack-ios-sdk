//
//  VersionUtilities.swift
//  NStack
//
//  Created by Kasper Welner on 20/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

enum VersionUtilities {
    internal static var versionOverride: String?

    static var previousAppVersion: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.CacheKeys.previousVersion) ?? currentAppVersion
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.CacheKeys.previousVersion)
        }
    }

    static var lastUpdatedIso8601DateString: String {
        get {
            return lastUpdatedDate?.iso8601 ?? ""
        }
        set {
            if #available(iOS 10.0, OSX 10.12, *) {
                if let date = DateFormatter.iso8601.date(from: newValue) {
                    lastUpdatedDate = date
                }
            } else {
                if let date = DateFormatter.iso8601Fallback.date(from: newValue) {
                    lastUpdatedDate = date
                }
            }
        }
    }

    static var lastUpdatedDate: Date? {
        get {
            return NStack.sharedInstance.localizationManager?.lastUpdatedDate
        }
        set {
            NStack.sharedInstance.localizationManager?.lastUpdatedDate = newValue
        }
    }

    static var currentAppVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    static func isVersion(_ versionA: String, greaterThanVersion versionB: String) -> Bool {
        var versionAArray = versionA.components(separatedBy: ".")
        var versionBArray = versionB.components(separatedBy: ".")
        let maxCharCount = max(versionAArray.count, versionBArray.count)

        versionAArray = normalizedValuesFromArray(versionAArray, maxValues: maxCharCount)
        versionBArray = normalizedValuesFromArray(versionBArray, maxValues: maxCharCount)
        for val in 0..<maxCharCount {
            if  versionAArray[val] > versionBArray[val] {
                return true
            } else if versionAArray[val] < versionBArray[val] {
                return false
            }
        }

        return false
    }

    static func normalizedValuesFromArray(_ array: [String], maxValues: Int) -> [String] {
        guard array.count < maxValues else {
            return array
        }

        return array + [String](repeating: "0", count: maxValues - array.count)
    }
}
