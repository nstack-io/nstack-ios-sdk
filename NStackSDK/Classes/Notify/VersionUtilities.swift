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
            return UserDefaults.standard.string(forKey: Constants.CacheKeys.lastUpdatedDate) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.CacheKeys.lastUpdatedDate)
        }
    }

    static var lastUpdatedDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: Constants.CacheKeys.lastUpdatedDate) as? Date
        }
        set {
            if let date = newValue {
                UserDefaults.standard.setCodable(date, forKey: Constants.CacheKeys.lastUpdatedDate)
            }
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
