//
//  NStackVersionUtils.swift
//  NStack
//
//  Created by Kasper Welner on 20/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

struct NStackVersionUtils {
    
    private static let previousVersionKey = "PreviousVersionKey"
    
    static func currentAppVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? ""
    }
    
    static func previousAppVersion() -> String {
        return  NSUserDefaults.standardUserDefaults().stringForKey(previousVersionKey) ?? currentAppVersion()
    }
    
    static func setPreviousAppVersion(version:String) {
        NSUserDefaults.standardUserDefaults().setObject(version, forKey: previousVersionKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func isVersion(versionA:String, greaterThanVersion versionB:String) -> Bool {
        
        var versionAArray = versionA.componentsSeparatedByString(".")
        var versionBArray = versionB.componentsSeparatedByString(".")
        let maxCharCount = max(versionAArray.count, versionBArray.count)
        
        versionAArray = normalizedValuesFromArray(versionAArray, maxValues: maxCharCount)
        versionBArray = normalizedValuesFromArray(versionBArray, maxValues: maxCharCount)
        
        for i in 0..<maxCharCount {
            if  versionAArray[i] > versionBArray[i] {
                return true
            } else if versionAArray[i] < versionBArray[i] {
                return false;
            }
        }
        return false;
    }
    
    
    static func normalizedValuesFromArray(array:[String], maxValues:Int) -> [String] {
        var arrayCopy = array
        
        if arrayCopy.count < maxValues {
            let difference = maxValues - arrayCopy.count
            for _ in 0..<difference {
                arrayCopy.append("0")
            }
            
            return arrayCopy
            
        } else {
            return array;
        }
    }
}