//
//  TranslationManagerTests.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import XCTest
@testable import NStackSDK

class TranslationManagerTests: XCTestCase {

    var repositoryMock: TranslationsRepositoryMock!
    var manager: TranslationManager!

    var mockTranslations: TranslationsResponse {
        let lang = LanguageData(language: Language(id: 0, name: "Danish", locale: "da-DK", direction: "lrm", acceptLanguage: "da-DK"))
        let response = TranslationsResponse(translations:
            ["en-GB" :
                [
                    "default" : ["englishKey" : "englishValue"]
                ],
             "da-DK" :
                [
                    "section1" : ["testKey" : "testValue"],
                    "section2" : ["key2" : "value2"]
                ]
            ], languageData: lang)
        return response
    }

    override func setUp() {
        super.setUp()
        repositoryMock = TranslationsRepositoryMock()
        manager = TranslationManager(translationsType: Translations.self, repository: repositoryMock)
    }

    override func tearDown() {
        super.tearDown()
        manager.persistedTranslations = nil
        manager = nil
        repositoryMock = nil
    }

    func testAcceptLanguage() {
        // Test simple language
        repositoryMock.preferredLanguages = ["en"]
        XCTAssertEqual(manager.acceptLanguage, "en;q=1.0")

        // Test two languages with locale
        repositoryMock.preferredLanguages = ["da-DK", "en-GB"]
        XCTAssertEqual(manager.acceptLanguage, "da-DK;q=1.0,en-GB;q=0.9")

        // Test max lang limit
        repositoryMock.preferredLanguages = ["da-DK", "en-GB", "en", "cs-CZ", "sk-SK", "no-NO"]
        XCTAssertEqual(manager.acceptLanguage,
                       "da-DK;q=1.0,en-GB;q=0.9,en;q=0.8,cs-CZ;q=0.7,sk-SK;q=0.6",
                       "There should be maximum 5 accept languages.")

        // Test fallback
        repositoryMock.preferredLanguages = []
        XCTAssertEqual(manager.acceptLanguage, "en;q=1.0",
                       "If no accept language there should be fallback to english.")
    }

    func testOverrideLanguage() {
        // TODO: Add more tests
    }

    func testPersistedTranslations() {
        repositoryMock.translationsResponse = mockTranslations
        manager.updateTranslations()
        XCTAssertNotNil(manager.persistedTranslations, "Persisted translations should be available.")
    }

    func testFallbackTranslations() {
        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should be available.")
    }

    func testClearTranslations() {
        _ = manager.loadFallbackTranslations() as Translations
        XCTAssertNotNil(manager.translationsObject, "Translations shouldn't be nil.")
        manager.clearTranslations()
        XCTAssertNil(manager.translationsObject, "Translations should not exist after clear.")
    }

    func testClearPersistedTranslations() {
        repositoryMock.translationsResponse = mockTranslations
        manager.updateTranslations { error in
            XCTAssertNotNil(self.manager.persistedTranslations, "Persisted translations should exist.")
            self.manager.clearTranslations(includingPersisted: true)
            XCTAssertNil(self.manager.persistedTranslations, "Persisted translations should not exist after clear.")
        }
    }
}
