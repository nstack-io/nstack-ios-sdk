//
//  Repository.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif

public typealias Result<T> = Swift.Result<T, Error>

public typealias Completion<T> = ((Result<T>) -> Void)

typealias Repository =
    AppOpenRepository &
    UpdatesRepository &
    GeographyRepository &
    ValidationRepository &
    ContentRepository &
    ColletionRepository &
    VersionsRepository &
    LocalizationRepository &
    LocalizationContextRepository &
    ProposalsRepository &
    FeedbackRepository

// MARK: - App Open -

protocol AppOpenRepository {
    func postAppOpen(oldVersion: String,
                     currentVersion: String,
                     acceptLanguage: String?,
                     completion: @escaping Completion<AppOpenResponse>)
}

// MARK: - Updates -

protocol UpdatesRepository {
    func fetchUpdates(oldVersion: String, currentVersion: String,
                      completion: @escaping Completion<Update>)
}

// MARK: - Geography -

protocol GeographyRepository {
    func fetchContinents(completion: @escaping Completion<[Continent]>)
    func fetchCountries(completion: @escaping Completion<[Country]>)
    func fetchLanguages(completion: @escaping Completion<[DefaultLanguage]>)
    func fetchTimeZones(completion: @escaping Completion<[Timezone]>)
    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>)
    func fetchIPDetails(completion: @escaping Completion<IPAddress>)
}

// MARK: - Validation -

protocol ValidationRepository {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>)
}

// MARK: - Content -

protocol ContentRepository {
    func fetchStaticResponse<T: Codable>(_ slug: String, completion: @escaping Completion<T>)
}

// MARK: - Collection -

protocol ColletionRepository {
    func fetchCollection<T: Codable>(_ id: Int, completion: @escaping ((Result<T>) -> Void))
}

// MARK: - Versions -

protocol VersionsRepository {
    func markWhatsNewAsSeen(_ id: Int)
    func markMessageAsRead(_ id: Int)

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult)
    #endif
}

// MARK: - Proposals -

protocol ProposalsRepository {
    func storeProposal(section: String, key: String, value: String, locale: String, completion: @escaping Completion<Proposal>)
    func fetchProposals(completion: @escaping Completion<[Proposal]>)
    func deleteProposal(_ proposal: Proposal, completion: @escaping (Result<ProposalDeletion>) -> Void)
}

// MARK: - Feedback -

protocol FeedbackRepository {
    func provideFeedback(_ feedback: Feedback, completion: @escaping Completion<Void>)
}
