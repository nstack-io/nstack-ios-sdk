//
//  LocalizationRepository.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

/// {sourcery: AutoMockable: D=DefaultLocalizationDescriptor, L=DefaultLanguage}
public protocol LocalizationRepository {
    func getLocalizationDescriptors<D: LocalizationDescriptor>(
        acceptLanguage: String,
        lastUpdated: Date?,
        completion: @escaping (Result<[D]>) -> Void
        )

    func getLocalization<L: LanguageModel, D: LocalizationDescriptor>(
        descriptor: D,
        acceptLanguage: String,
        completion: @escaping (Result<LocalizationResponse<L>>) -> Void
        )

    func getAvailableLanguages<L: LanguageModel>(
        completion:  @escaping (Result<[L]>) -> Void
    )
}

/// sourcery: AutoMockable
public protocol LocalizationContextRepository {
    func fetchPreferredLanguages() -> [String]
    func getLocalizationBundles() -> [Bundle]
    func fetchCurrentPhoneLanguage() -> String?
}
