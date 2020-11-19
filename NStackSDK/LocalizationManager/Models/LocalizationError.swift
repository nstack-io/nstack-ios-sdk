//
//  LocalizationError.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public enum LocalizationError: Error {
    case invalidKeyPath
    case updateFailed(_ error: Error)
    case localizationsConfigFileUrlUnavailable
    case localizationFileUrlUnavailable
    case noLocaleFound
    case noLocalizationsFound
    case loadingFallbackLocalizationsFailed
    case unknown

    public var localizedDescription: String {
        switch self {
        case .invalidKeyPath: return "Key path should only consist of section and key components."
        case .updateFailed(let error): return "Localizations update has failed to download: \(error.localizedDescription)"
        case .localizationFileUrlUnavailable: return "Couldn't get localizations file url."
        case .localizationsConfigFileUrlUnavailable: return "Couldn't get localizations config file url."
        case .noLocalizationsFound: return "Didn't find any suitable localizations in the localizations file."
        case .loadingFallbackLocalizationsFailed: return "Loading fallback localizations has failed."
        case .unknown: return "Uknown error happened."
        case .noLocaleFound:
            return "Could not find a Locale Identifier in the Localizations Response"
        }
    }
}
