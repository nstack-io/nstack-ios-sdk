//
//  Configuration.swift
//  NStack
//
//  Created by Dominik Hádl on 12/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import Serpent

public struct UpdateOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let onStart = UpdateOptions(rawValue: 1 << 0)
    public static let onDidBecomeActive = UpdateOptions(rawValue: 2 << 1)
    public static let never = UpdateOptions(rawValue: 2 << 2)
}

public struct Configuration {

    public let appId: String
    public let restAPIKey: String
    public let translationsClass: Translatable.Type?
    public var updateOptions: UpdateOptions = [.onStart, .onDidBecomeActive]
    public var verboseMode = false
    public var flat = false
    public var translationsUrlOverride: String?

    // Used for tests
    internal var versionOverride: String?

    fileprivate static let UUIDKey = "NSTACK_UUID_DEFAULTS_KEY"

    internal static var guid: String {
        let savedUUID = UserDefaults.standard.object(forKey: UUIDKey)
        if let UUID = savedUUID as? String {
            return UUID
        }

        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: UUIDKey)
        UserDefaults.standard.synchronize()
        return newUUID
    }

    public init(appId: String,
                restAPIKey: String,
                translationsClass: Translatable.Type? = nil,
                flatTranslations: Bool = false,
                translationsUrlOverride: String? = nil) {
        self.appId = appId
        self.restAPIKey = restAPIKey
        self.translationsClass = translationsClass
        self.flat = flatTranslations
        self.translationsUrlOverride = translationsUrlOverride
    }

    public init(plistName: String, translationsClass: Translatable.Type? = nil) {
        var appId: String?
        var restAPIKey: String?
        var flatString: String?
        var translationsUrlOverride: String?

        for bundle in Bundle.allBundles {
            let fileName = plistName.replacingOccurrences(of: ".plist", with: "")
            if let fileURL = bundle.url(forResource: fileName, withExtension: "plist") {

                let object = NSDictionary(contentsOf: fileURL)

                guard let keyDict = object as? [String : AnyObject] else {
                    fatalError("Can't parse file \(fileName).plist")
                }

                appId = keyDict["APPLICATION_ID"] as? String
                restAPIKey = keyDict["REST_API_KEY"] as? String
                flatString = keyDict["FLAT"] as? String
                translationsUrlOverride = keyDict["TRANSLATIONS_URL"] as? String
                break
            }
        }

        guard let finalAppId = appId else { fatalError("Couldn't initialize appId") }
        guard let finalRestAPIKey = restAPIKey else { fatalError("Couldn't initialize REST API key") }

        self.appId = finalAppId
        self.restAPIKey = finalRestAPIKey
        self.translationsClass = translationsClass
        self.translationsUrlOverride = translationsUrlOverride

        if let flat = flatString, flat == "1" {
            self.flat = true
        }
    }
}
