//
//  AcceptLanguageProvider.swift
//  LocalizationManager
//
//  Created by Dominik Hádl on 27/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public protocol AcceptLanguageProviderType: class {

    /// Creates the accept language provider.
    ///
    /// - Parameter repository: A localization context repository,
    ///                         where preferred languages are fetched from.
    init(repository: LocalizationContextRepository)

    /// Returns a string containing the current locale's preferred languages in a prioritized
    /// manner to be used in a accept-language header. If no preferred language available,
    /// fallback language is returned (English). Format example:
    ///
    /// "da;q=1.0,en-gb;q=0.8,en;q=0.7"
    ///
    /// - Parameter languageOverride: Optionally provide a locale override.
    /// - Returns: An acceptLanguage string that can be used as header value.
    func createHeaderString(languageOverride: Locale?) -> String
}

/// Provider used to generate the accept language header string for network requests.
public final class AcceptLanguageProvider: AcceptLanguageProviderType {

    /// The context repository to get preferred languages from.
    private let repository: LocalizationContextRepository

    /// Creates the accept language provider.
    ///
    /// - Parameter repository: A localization context repository,
    ///                         where preferred languages are fetched from.
    public init(repository: LocalizationContextRepository) {
        self.repository = repository
    }

    public func createHeaderString(languageOverride: Locale? = nil) -> String {
        var components: [String] = []
        var quality = 1.0

        // If we have language override, then append custom language code
        if let override = languageOverride {
            components.append(override.identifier + ";q=\(quality)")
            quality -= 0.1
        }

        // Get the preferred languages for the user/device
        var languages = repository.fetchPreferredLanguages()

        // Append fallback language if we don't have any provided
        if components.isEmpty && languages.isEmpty {
            languages.append("en")
        }

        // Calculate the end value, by taking the quality and subtracting 0.1 as many times
        // as there is languages. Then the maximum value is taken between the calculated
        // and 0.5, resulting in maximum 5 languages in the header string.
        let startValue = 1.0 - (0.1 * Double(components.count))
        let endValue = startValue - (0.1 * Double(languages.count))

        // Goes through max quality to the lowest (or 0.5, whichever is higher) by 0.1 decrease
        // and appends a component with the language code and quality, like this:
        // en-gb;q=1.0
        for quality in stride(from: startValue, to: max(endValue, 0.5), by: -0.1) {
            components.append("\(languages.removeFirst());q=\(quality)")
        }

        // Joins all components together to get "da;q=1.0,en-gb;q=0.8" string
        return components.joined(separator: ",")
    }
}
