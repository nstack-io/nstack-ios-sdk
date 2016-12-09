//
//  TranslationManagerTests.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import XCTest
import Cashier
@testable import NStackSDK

class TranslationManagerTests: XCTestCase {

    let store = NOPersistentStore.cache(withId: "TranslationManagerTests")!
    var repositoryMock: TranslationsRepositoryMock!
    var fileManagerMock: FileManagerMock!
    var manager: TranslationManager!

    let mockLanguage = Language(id: 0, name: "Danish", locale: "da-DK",
                                direction: "lrm", acceptLanguage: "da-DK")

    var mockTranslations: TranslationsResponse {
        return TranslationsResponse(translations:
            ["en-GB" :
                [
                    "default" : ["successKey" : "SuccessUpdated"]
                ],
             "da-DK" :
                [
                    "default" : ["successKey" : "FedtUpdated"]
                ]
            ], languageData: LanguageData(language: mockLanguage))
    }

    var testTranslations: Translations {
        return manager.translations()
    }

    var mockBundle: BundleMock {
        let path = fileManagerMock.urls(for: .cachesDirectory, in: .userDomainMask)[0].absoluteString
        return BundleMock(path: path.replacingOccurrences(of: "file://", with: ""))!
    }

    var invalidTranslationsJSONPath: String {
        return Bundle(for: type(of: self)).resourcePath! + "/InvalidTranslations.json"
    }

    var wrongFormatJSONPath: String {
        return Bundle(for: type(of: self)).resourcePath! + "/WrongTypeTranslations.json"
    }

    // MARK: - Test Case Lifecycle -

    override func setUp() {
        super.setUp()
        repositoryMock = TranslationsRepositoryMock()
        fileManagerMock = FileManagerMock()
        manager = TranslationManager(translationsType: Translations.self,
                                     repository: repositoryMock,
                                     logger: Logger(),
                                     store: store,
                                     fileManager: fileManagerMock)
    }

    override func tearDown() {
        super.tearDown()
        manager.persistedTranslations = nil
        manager = nil
        repositoryMock = nil
        fileManagerMock = nil
        store.clearAllData(true)
    }

    // MARK: - Loading -

    func testLoadTranslations() {
        XCTAssertNil(manager.translationsObject)
        manager.loadTranslations()
        XCTAssertNotNil(manager.translationsObject,
                        "Translations object shouldn't be nil after loading.")
    }

    // MARK: - Update -

    func testUpdateSuccess() {
        repositoryMock.translationsResponse = mockTranslations
        XCTAssertNil(manager.synchronousUpdateTranslations(), "Error should be nil.")
        XCTAssertNotNil(manager.translationsObject,
                        "Translations should be loaded after successful update.")
        XCTAssertNotNil(manager.persistedTranslations,
                        "Persistent translations should be saved after successful update.")
    }

    func testUpdateFailure() {
        repositoryMock.translationsResponse = nil
        XCTAssertNotNil(manager.synchronousUpdateTranslations(), "Error shouldn't be nil.")
        XCTAssertNil(manager.translationsObject,
                     "Translations should not be loaded after failed update.")
        XCTAssertNil(manager.persistedTranslations,
                     "Persistent translations should not be saved after failed update.")
    }

    // MARK: - Fetch -

    func testFetchCurrentLanguageSuccess() {
        repositoryMock.currentLanguage = mockLanguage
        let exp = expectation(description: "Fetch language should return one language.")
        manager.fetchCurrentLanguage { (response) in
            if case let .success(lang) = response.result {
                XCTAssertEqual(lang.name, self.mockLanguage.name)
            } else {
                XCTAssert(false)
            }

            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchCurrentLanguageFailure() {
        repositoryMock.currentLanguage = nil
        let exp = expectation(description: "Fetch language should fail without language.")
        manager.fetchCurrentLanguage { (response) in
            if case .success(_) = response.result {
                XCTAssert(false)
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchAvailableLanguagesSuccess() {
        repositoryMock.availableLanguages = [
            Language(id: 0, name: "English", locale: "en-GB",
                     direction: "LRM", acceptLanguage: "en-GB"),
            Language(id: 1, name: "Danish", locale: "da-DK",
                     direction: "LRM", acceptLanguage: "da-DK")
        ]

        let exp = expectation(description: "Fetch available should return two languages.")
        manager.fetchAvailableLanguages { (response) in
            if case .failure(_) = response.result {
                XCTAssert(false)
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchAvailableLanguagesFailure() {
        repositoryMock.availableLanguages = nil
        let exp = expectation(description: "Fetch available should fail without languages.")
        manager.fetchAvailableLanguages { (response) in
            if case .success(_) = response.result {
                XCTAssert(false)
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    // MARK: - Accept -

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

    func testLastAcceptHeader() {
        XCTAssertNil(manager.lastAcceptHeader, "Last accept header should be nil at start.")
        manager.lastAcceptHeader = "da-DK;q=1.0,en;q=1.0"
        XCTAssertEqual(manager.lastAcceptHeader, "da-DK;q=1.0,en;q=1.0")
        manager.lastAcceptHeader = nil
        XCTAssertNil(manager.lastAcceptHeader, "Last accept header should be nil.")
    }

    // MARK: - Language Override -

    func testLanguageOverride() {
        XCTAssertEqual(testTranslations.defaultSection.successKey, "Success")
        manager.languageOverride = mockLanguage
        XCTAssertEqual(testTranslations.defaultSection.successKey, "Fedt")
    }

    func testLanguageOverrideStore() {
        XCTAssertNil(manager.languageOverride, "Language override should be nil at start.")
        manager.languageOverride = mockLanguage
        XCTAssertNotNil(manager.languageOverride)
        manager.languageOverride = nil
        XCTAssertNil(manager.languageOverride, "Language override should be nil.")
    }

    func testLanguageOverrideClearTranslations() {
        // Load translations
        manager.loadTranslations()
        XCTAssertNotNil(manager.translationsObject,
                        "Translations shouldn't be nil after loading.")

        // Override lang, should clear all loaded
        manager.languageOverride = mockLanguage
        XCTAssertNil(manager.translationsObject,
                     "Translations should be cleared if language is overriden.")

        // Accessing again should load with override lang
        _ = manager.translations() as Translations
        XCTAssertNotNil(manager.translationsObject,
                        "Translations should load with language override.")
    }

    // MARK: - Translations -

    func testTranslationsMemoryCache() {
        XCTAssertNil(manager.translationsObject)
        XCTAssertEqual(testTranslations.defaultSection.successKey, "Success")
        XCTAssertNotNil(manager.translationsObject)
        XCTAssertEqual(testTranslations.defaultSection.successKey, "Success")
    }

    // MARK: - Translation Dictionaries -

    func testPersistedTranslations() {
        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil at start.")
        manager.persistedTranslations = mockTranslations.translations
        XCTAssertNotNil(manager.persistedTranslations)
        manager.persistedTranslations = nil
        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil.")
    }

    func testPersistedTranslationsSaveFailure() {
        fileManagerMock.searchPathUrlsOverride = []
        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil at start.")
        manager.persistedTranslations = mockTranslations.translations
        XCTAssertNil(manager.persistedTranslations, "There shouldn't be any saved translations.")
    }

    func testPersistedTranslationsSaveFailureBadUrl() {
        fileManagerMock.searchPathUrlsOverride = [URL(string: "test://")!]
        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil at start.")
        manager.persistedTranslations = mockTranslations.translations
        XCTAssertNil(manager.persistedTranslations, "There shouldn't be any saved translations.")
    }

    func testPersistedTranslationsOnUpdate() {
        repositoryMock.translationsResponse = mockTranslations
        XCTAssertNil(manager.synchronousUpdateTranslations(), "No error should happen on update.")
        XCTAssertNotNil(manager.persistedTranslations, "Persisted translations should be available.")
    }

    func testFallbackTranslations() {
        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should be available.")
    }

    func testFallbackTranslationsInvalidPath() {
        let bundle = mockBundle
        bundle.resourcePathOverride = "file://BlaBlaBla.json" // invalid path
        repositoryMock.customBundles = [bundle]
        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should fail with invalid path.")
    }

    func testFallbackTranslationsInvalidJSON() {
        let bundle = mockBundle
        bundle.resourcePathOverride = invalidTranslationsJSONPath // invalid json file
        repositoryMock.customBundles = [bundle]
        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should fail with invalid JSON.")
    }

    func testFallbackTranslationsWrongFormatJSON() {
        let bundle = mockBundle
        bundle.resourcePathOverride = wrongFormatJSONPath // wrong format json file
        repositoryMock.customBundles = [bundle]
        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should fail with wrong format JSON.")
    }

    // MARK: - Unwrap & Parse -

    func testUnwrapAndParse() {
        let wrapped = NSDictionary(dictionary: ["data" : mockTranslations.translations!])
        repositoryMock.preferredLanguages = ["da"]
        let final = manager.processAllTranslations(wrapped)
        XCTAssertNotNil(final, "Unwrap and parse should succeed.")
        XCTAssertEqual(final?.value(forKeyPath: "default.successKey") as? String, Optional("FedtUpdated"))
    }

    // MARK: - Extraction -

    func testExtractWithFullLocale() {
        repositoryMock.preferredLanguages = ["en-GB", "da-DK"]
        let lang: NSDictionary = ["da-DK" : ["correct" : "no"],
                                  "en-GB" : ["correct" : "yes"]]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
    }

    func testExtractWithShortLocale() {
        repositoryMock.preferredLanguages = ["da"]
        let lang: NSDictionary = ["da-DK" : ["correct" : "yes"],
                                  "en-GB" : ["correct" : "no"]]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
    }

    func testExtractWithLanguageOverride() {
        repositoryMock.preferredLanguages = ["en-GB", "en"]
        manager.languageOverride = mockLanguage
        let lang: NSDictionary = ["en-GB" : ["correct" : "no"],
                                  "da-DK" : ["correct" : "yes"]]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
    }

    func testExtractWithWrongLanguageOverride() {
        repositoryMock.preferredLanguages = ["en-GB", "en"]
        manager.languageOverride = mockLanguage
        let lang: NSDictionary = ["en" : ["correct" : "yes"]]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
    }

    func testExtractWithNoLocale() {
        repositoryMock.preferredLanguages = []
        let lang: NSDictionary = ["da-DK" : ["correct" : "no"],
                                  "en-GB" : ["correct" : "yes"]]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
    }

    func testExtractWithNoLocaleAndNoEnglish() {
        repositoryMock.preferredLanguages = []
        let lang: NSDictionary = ["es" : ["correct" : "no"],
                                  "da-DK" : ["correct" : "yes"]]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
    }

    func testExtractFailure() {
        repositoryMock.preferredLanguages = ["da-DK"]
        let lang: NSDictionary = [:]
        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict.allKeys.count, 0, "Extracted dictionary should not be empty.")
    }

    // MARK: - Clearing -

    func testClearTranslations() {
        manager.loadTranslations()
        XCTAssertNotNil(manager.translationsObject, "Translations shouldn't be nil.")
        manager.clearTranslations()
        XCTAssertNil(manager.translationsObject, "Translations should not exist after clear.")
    }

    func testClearPersistedTranslations() {
        repositoryMock.translationsResponse = mockTranslations
        XCTAssertNil(manager.synchronousUpdateTranslations())
        XCTAssertNotNil(manager.persistedTranslations, "Persisted translations should exist.")
        manager.clearTranslations(includingPersisted: true)
        XCTAssertNil(manager.persistedTranslations, "Persisted translations should not exist after clear.")
    }
}

// MARK: - Helpers -

extension TranslationManager {
    fileprivate func synchronousUpdateTranslations() -> NStackError.Translations? {
        let semaphore = DispatchSemaphore(value: 0)
        var error: NStackError.Translations?

        updateTranslations { e in
            error = e
            semaphore.signal()
        }
        semaphore.wait()

        return error
    }
}
