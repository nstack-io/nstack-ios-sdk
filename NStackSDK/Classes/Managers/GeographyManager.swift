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
#endif
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
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
    public func ipDetails(completion: @escaping Completion<IPAddress>) {
        repository.fetchIPDetails(completion: completion)
    }

    // MARK: - Countries

    /// Updates the list of countries stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func countries(completion: @escaping Completion<[Country]>) {
        repository.fetchCountries { (result) in
            switch result {
            case .success:
                completion(result)
            case .failure:
                do {
                    let countries = try self.fallbackCountries()
                    completion(.success(countries))
                } catch {
                    completion(result)
                }
            }
        }
    }

     /// Loads the local JSON copy, has a return value so that it can be synchronously
    /// loaded the first time they're needed.
    ///
    /// - Returns: A dictionary representation of the selected local translations set.
    private func fallbackCountries() throws -> [Country] {
        // Iterate through bundle until we find the translations file
        for bundle: Bundle in Bundle.allFrameworks {
            // Check if bundle contains translations file, otheriwse continue with next bundle
            guard let filePath = bundle.path(forResource: "Countries", ofType: "json") else {
                continue
            }

            let fileUrl = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: fileUrl)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([Country].self, from: data)
        }

        throw NStackError.GeographyManager.noResourceAvailable
    }

    // MARK: - Continents
    /// Updates the list of continents stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func continents(completion: @escaping Completion<[Continent]>) {
        repository.fetchContinents(completion: completion)
    }

    // MARK: - Languages
    /// Updates the list of languages stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func languages(completion: @escaping Completion<[DefaultLanguage]>) {
        repository.fetchLanguages(completion: completion)
    }

    // MARK: - Timezones
    /// Updates the list of timezones stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func timezones(completion: ((_ countries: [Timezone], _ error: Error?) -> Void)? = nil) {
        repository.fetchTimeZones { (result) in
            switch result {
            case .success(let data):
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            }
        }
    }

    /// Get timezone for latitude and longitude
    ///
    /// - Parameters
    ///     lat: A double representing the latitude
    ///     lgn: A double representing the longitude
    ///     completion: Completion block when the API call has finished.
    public func timezone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        repository.fetchTimeZone(lat: lat, lng: lng, completion: completion)
    }
}
