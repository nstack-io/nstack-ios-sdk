//
//  TranslationError.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public enum TranslationError: Error {
    case invalidKeyPath
    case updateFailed(_ error: Error)
    case localizationsConfigFileUrlUnavailable
    case translationsFileUrlUnavailable
    case noLocaleFound
    case noTranslationsFound
    case loadingFallbackTranslationsFailed
    case unknown

    public var localizedDescription: String {
        switch self {
        case .invalidKeyPath: return "Key path should only consist of section and key components."
        case .updateFailed(let error): return "Translations update has failed to download: \(error.localizedDescription)"
        case .translationsFileUrlUnavailable: return "Couldn't get translations file url."
        case .localizationsConfigFileUrlUnavailable: return "Couldn't get localizations config file url."
        case .noTranslationsFound: return "Didn't find any suitable translations in the translations file."
        case .loadingFallbackTranslationsFailed: return "Loading fallback translations has failed."
        case .unknown: return "Uknown error happened."
        case .noLocaleFound:
            return "Could not find a Locale Identifier in the Translations Response"
        }
    }
}
