//
//  GeographyManager.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 28/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import TranslationManager

public class GeographyManager {

    // MARK: - Properites
    internal var repository: GeographyRepository

    // MARK: - Init
    init(repository: GeographyRepository) {
        self.repository = repository
    }

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
        repository.fetchCountries(completion: completion)
    }

    /// Locally stored list of countries
    private(set) var countries: [Country]? {
        get {
            // FIXME: Load from disk on load
            return nil
            //            return Constants.persistentStore.serializableForKey(Constants.CacheKeys.countries)
        }
        set {
            // FIXME: Save to disk or delete
            //            guard let newValue = newValue else {
            //                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.countries, purgeMemoryCache: true)
            //                return
            //            }
            //            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.countries)
        }
    }

    // MARK: - Continents
    /// Updates the list of continents stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    func updateContinents(completion: @escaping Completion<[Continent]>) {
        repository.fetchContinents(completion: completion)
    }

    /// Locally stored list of continents
    private(set) var continents: [Continent]? {
        get {
            // FIXME: Load from disk on start
            //            return Constants.persistentStore.serializableForKey(Constants.CacheKeys.continents)
            return nil
        }
        set {
            // FIXME: Save/delete to disk
            //            guard let newValue = newValue else {
            //                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.continents, purgeMemoryCache: true)
            //                return
            //            }
            //            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.continents)
        }
    }

    // MARK: - Languages
    /// Updates the list of languages stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    func updateLanguages(completion: @escaping Completion<[Language]>) {
        repository.fetchLanguages(completion: completion)
    }

    /// Locally stored list of languages
    private(set) var languages: [Language]? {
        get {
            // FIXME: Load from disk on start
            //return Constants.persistentStore.serializableForKey(Constants.CacheKeys.languanges)
            return nil
        }
        set {
            // FIXME: Save/delete to disk
            //            guard let newValue = newValue else {
            //                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.languanges, purgeMemoryCache: true)
            //                return
            //            }
            //            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.languanges)
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
            // FIXME: Load from disk on start
            //            return Constants.persistentStore.serializableForKey(Constants.CacheKeys.timezones)
            return nil
        }
        set {
            // FIXME: Save/delete to disk
            //            guard let newValue = newValue else {
            //                Constants.persistentStore.deleteSerializableForKey(Constants.CacheKeys.timezones, purgeMemoryCache: true)
            //                return
            //            }
            //            Constants.persistentStore.setSerializable(newValue, forKey: Constants.CacheKeys.timezones)
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
