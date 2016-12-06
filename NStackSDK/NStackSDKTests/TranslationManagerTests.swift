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

    override func setUp() {
        super.setUp()
        repositoryMock = TranslationsRepositoryMock()
        manager = TranslationManager(translationsType: Translations.self, repository: repositoryMock)
    }

    override func tearDown() {
        super.tearDown()
        manager = nil
        repositoryMock = nil
    }

    func testAcceptLanguage() {
        repositoryMock.preferredLanguages = ["en"]
        XCTAssertEqual(manager.acceptLanguage, "en;q=1.0")

        repositoryMock.preferredLanguages = ["da-DK", "en-GB"]
        XCTAssertEqual(manager.acceptLanguage, "da-DK;q=1.0,en-GB;q=1.0")

        // TODO: Add more tests
    }

    func testOverrideLanguage() {
        // TODO: Add more tests
    }

    func testPersistedTranslations() {
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
        repositoryMock.translationsResponse = response
        manager.updateTranslations()
        XCTAssertNotNil(manager.persistedTranslations, "Fallback translations should be available.")
    }

    func testFallbackTranslations() {
        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should be available.")
    }

    func testClearTranslations() {
        XCTAssertNotNil(manager.translationsObject, "Translations object shouldn't be nil.")
        manager.clearTranslations()
        XCTAssertNil(manager.translationsObject, "Translations should not exist after clear.")
    }

    func testClearPersistedTranslations() {
        XCTAssertNotNil(manager.persistedTranslations, "Persisted translations should exist.")
        manager.clearTranslations(includingPersisted: true)
        XCTAssertNil(manager.persistedTranslations, "Persisted translations should not exist after clear.")
    }
}
