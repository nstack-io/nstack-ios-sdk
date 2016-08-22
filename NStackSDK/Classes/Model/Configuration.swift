//
//  Configuration.swift
//  NStack
//
//  Created by Dominik Hádl on 12/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Serializable

public struct UpdateOptions: OptionSetType {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let OnStart = UpdateOptions(rawValue: 1 << 0)
    public static let OnDidBecomeActive = UpdateOptions(rawValue: 1 << 1)
}

public struct Configuration {

    public let appId: String
    public let restAPIKey: String
    public let translationsClass: Translatable.Type?
    public var updateOptions: UpdateOptions = [.OnStart, .OnDidBecomeActive]
    public var verboseMode = false
    public var flat = false

    // Used for tests
    internal var versionOverride: String?

    private static let UUIDKey = "NSTACK_UUID_DEFAULTS_KEY"

    internal static func guid() -> String {
        let savedUUID = NSUserDefaults.standardUserDefaults().objectForKey(UUIDKey)
        if let UUID = savedUUID as? String {
            return UUID
        }

        let newUUID = NSUUID().UUIDString
        NSUserDefaults.standardUserDefaults().setObject(newUUID, forKey: UUIDKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        return newUUID
    }

    public init(appId: String, restAPIKey: String, translationsClass: Translatable.Type? = nil) {
        self.appId = appId
        self.restAPIKey = restAPIKey
        self.translationsClass = translationsClass
    }

    public init(plistName: String, translationsClass: Translatable.Type? = nil) {
        var appId:String?
        var restAPIKey:String?
        var flatString:String?

        for bundle in NSBundle.allBundles() {
            let fileName = plistName.stringByReplacingOccurrencesOfString(".plist", withString: "")
            if let fileURL = bundle.URLForResource(fileName, withExtension: "plist") {

                let object = NSDictionary(contentsOfURL: fileURL)

                guard let keyDict = object as? [String : AnyObject] else {
                    fatalError("Can't parse file \(fileName).plist")
                }

                appId = keyDict["APPLICATION_ID"] as? String
                restAPIKey = keyDict["REST_API_KEY"] as? String
                flatString = keyDict["FLAT"] as? String
                break
            }
        }

        guard let finalAppId = appId else { fatalError("Couldn't initialize appId") }
        guard let finalRestAPIKey = restAPIKey else { fatalError("Couldn't initialize REST API key") }

        self.appId = finalAppId
        self.restAPIKey = finalRestAPIKey
        self.translationsClass = translationsClass

        if let flat = flatString where flat == "1" {
            self.flat = true
        }
    }
}
