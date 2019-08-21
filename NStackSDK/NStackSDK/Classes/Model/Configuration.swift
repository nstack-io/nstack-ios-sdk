//
//  Configuration.swift
//  NStack
//
//  Created by Dominik Hádl on 12/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import TranslationManager
#elseif os(tvOS)
import TranslationManager_tvOS
#elseif os(watchOS)
import TranslationManager_watchOS
#elseif os(macOS)
import TranslationManager_macOS
#endif

public struct UpdateOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let onStart = UpdateOptions(rawValue: 1 << 0)
    public static let onDidBecomeActive = UpdateOptions(rawValue: 2 << 1)
    public static let never = UpdateOptions(rawValue: 2 << 2)
}

public struct Configuration {

    public enum NStackEnvironment: String {
        case debug
        case staging
        case production

        var isProduction: Bool {
            return self == .production
        }
    }

    public let appId: String
    public let restAPIKey: String
    public let translationsClass: LocalizableModel.Type
    public var updateOptions: UpdateOptions = [.onStart, .onDidBecomeActive]
    public var verboseMode = false
    public var flat = false
    public var useMock = false
    public var translationsUrlOverride: String?
    public var currentEnvironment: NStackEnvironment

    // Used for tests
    internal var versionOverride: String?

    fileprivate static let UUIDKey = "NSTACK_UUID_DEFAULTS_KEY"

    internal static var guid: String {
        if let UUID = UserDefaults.standard.string(forKey: UUIDKey) {
            return UUID
        }

        let newUUID = UUID().uuidString
        UserDefaults.standard.setValue(newUUID, forKey: UUIDKey)
        return newUUID
    }

    public init(appId: String,
                restAPIKey: String,
                translationsClass: LocalizableModel.Type,
                flatTranslations: Bool = false,
                translationsUrlOverride: String? = nil,
                environment: NStackEnvironment) {
        self.appId = appId
        self.restAPIKey = restAPIKey
        self.translationsClass = translationsClass
        self.flat = flatTranslations
        self.translationsUrlOverride = translationsUrlOverride
        self.currentEnvironment = environment
    }

    public init(plistName: String, environment: NStackEnvironment, translationsClass: LocalizableModel.Type) {
        var appId: String?
        var restAPIKey: String?
        var flatString: String?
        var translationsUrlOverride: String?

        self.currentEnvironment = environment

        for bundle in Bundle.allBundles {
            let fileName = plistName.replacingOccurrences(of: ".plist", with: "")
            if let fileURL = bundle.url(forResource: fileName, withExtension: "plist") {

                let object = NSDictionary(contentsOf: fileURL)

                guard let keyDict = object as? [String: AnyObject] else {
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

extension Configuration {
    var isProduction: Bool {
        return currentEnvironment.isProduction
    }
}
