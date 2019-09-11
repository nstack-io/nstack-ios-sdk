//
//  GeographyManager.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 28/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import LocalizationManager
#elseif os(tvOS)
import LocalizationManager_tvOS
#elseif os(watchOS)
import LocalizationManager_watchOS
#elseif os(macOS)
import LocalizationManager_macOS
#endif

public class GeographyManager {

    // MARK: - Properites
    internal var repository: GeographyRepository

    // MARK: - Init
    init(repository: GeographyRepository,
         userDefaults: UserDefaults = .standard) {
        self.repository = repository
        self.userDefaults = userDefaults
    }

    /// User defaults used to store basic information and settings.
    fileprivate let userDefaults: UserDefaults

    // MARK: - IPAddress
    /// Retrieve details based on the requestee's ip address
    ///
    /// - Parameter completion: Completion block when the API call has finished.
    func ipDetails(completion: @escaping Completion<IPAddress>) {
        repository.fetchIPDetails(completion: completion)
    }

    // MARK: - Countries

    /// Updates the list of countries stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    func updateCountries(completion: @escaping Completion<[Country]>) {
        repository.fetchCountries { (result) in
            switch result {
            case .success(let countries):
                self.countries = countries
            case .failure:
                break
            }
            completion(result)
        }
    }

    /// Locally stored list of countries
    private(set) var countries: [Country]? {
        get {
            return userDefaults.codable(forKey: Constants.CacheKeys.countries)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.CacheKeys.countries)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.CacheKeys.countries)
        }
    }

    // MARK: - Continents
    /// Updates the list of continents stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    func updateContinents(completion: @escaping Completion<[Continent]>) {
        repository.fetchContinents(completion: { (result) in
            switch result {
            case .success(let continents):
                self.continents = continents
            case .failure:
                break
            }
            completion(result)
        })
    }

    /// Locally stored list of continents
    private(set) var continents: [Continent]? {
        get {
            return userDefaults.codable(forKey: Constants.CacheKeys.continents)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.CacheKeys.continents)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.CacheKeys.continents)
        }
    }

    // MARK: - Languages
    /// Updates the list of languages stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    func updateLanguages(completion: @escaping Completion<[DefaultLanguage]>) {
        repository.fetchLanguages(completion: { (result) in
            switch result {
            case .success(let languages):
                self.languages = languages
            case .failure:
                break
            }
            completion(result)
        })
    }

    /// Locally stored list of languages
    private(set) var languages: [DefaultLanguage]? {
        get {
            return userDefaults.codable(forKey: Constants.CacheKeys.languanges)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.CacheKeys.languanges)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.CacheKeys.languanges)
        }
    }

    // MARK: - Timezones
    /// Updates the list of timezones stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    func updateTimezones(completion: ((_ countries: [Timezone], _ error: Error?) -> Void)? = nil) {
        repository.fetchTimeZones { (result) in
            switch result {
            case .success(let data):
                self.timezones = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            }
        }
    }

    /// Locally stored list of timezones
    private(set) var timezones: [Timezone]? {
        get {
            return userDefaults.codable(forKey: Constants.CacheKeys.timezones)
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: Constants.CacheKeys.timezones)
                return
            }
            userDefaults.setCodable(newValue, forKey: Constants.CacheKeys.timezones)
        }
    }

    /// Get timezone for latitude and longitude
    ///
    /// - Parameters
    ///     lat: A double representing the latitude
    ///     lgn: A double representing the longitude
    ///     completion: Completion block when the API call has finished.
    func timezone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        repository.fetchTimeZone(lat: lat, lng: lng, completion: completion)
    }
}
