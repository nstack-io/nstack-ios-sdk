//
//  VersionUtilities.swift
//  NStack
//
//  Created by Kasper Welner on 20/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

enum VersionUtilities {
    
    private static let previousVersionKey = "PreviousVersionKey"
    internal static var versionOverride: String?
    
    static func currentAppVersion() -> String {
        return Bundle.main().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? ""
    }
    
    static func previousAppVersion() -> String {
        return  UserDefaults.standard().string(forKey: previousVersionKey) ?? currentAppVersion()
    }
    
    static func setPreviousAppVersion(_ version:String) {
        UserDefaults.standard().set(version, forKey: previousVersionKey)
        UserDefaults.standard().synchronize()
    }
    
    static func isVersion(_ versionA:String, greaterThanVersion versionB:String) -> Bool {
        
        var versionAArray = versionA.components(separatedBy: ".")
        var versionBArray = versionB.components(separatedBy: ".")
        let maxCharCount = max(versionAArray.count, versionBArray.count)
        
        versionAArray = normalizedValuesFromArray(versionAArray, maxValues: maxCharCount)
        versionBArray = normalizedValuesFromArray(versionBArray, maxValues: maxCharCount)
        
        for i in 0..<maxCharCount {
            if  versionAArray[i] > versionBArray[i] {
                return true
            } else if versionAArray[i] < versionBArray[i] {
                return false
            }
        }

        return false
    }

    static func normalizedValuesFromArray(array: [String], maxValues: Int) -> [String] {
        guard array.count < maxValues else {
            return array
        }

        return array + [String](count: maxValues - array.count, repeatedValue: "0")
    }
}
