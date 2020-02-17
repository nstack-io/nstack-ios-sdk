////
////  TranslationManagerTests.swift
////  NStackSDK
////
////  Created by Dominik Hádl on 15/08/16.
////  Copyright © 2016 Nodes ApS. All rights reserved.
////
//
//import XCTest
//import Cashier
//@testable import NStackSDK
//
//class TranslationManagerTests: XCTestCase {
//
//    let store = NOPersistentStore.cache(withId: "TranslationManagerTests")!
//    var repositoryMock: TranslationsRepositoryMock!
//    var fileManagerMock: FileManagerMock!
//    var manager: TranslationManager!
//    var logger: LoggerType!
//
//    let mockLanguage = Language(id: 0, name: "Danish", locale: "da-DK",
//                                direction: "lrm", acceptLanguage: "da-DK")
//
//    var mockTranslations: TranslationsResponse {
//        return TranslationsResponse(translations:
//            ["en-GB" :
//                [
//                    "default" : ["successKey" : "SuccessUpdated"]
//                ],
//             "da-DK" :
//                [
//                    "default" : ["successKey" : "FedtUpdated"]
//                ]
//            ], languageData: LanguageData(language: mockLanguage))
//    }
//
//    var mockWrappedTranslations: TranslationsResponse {
//        var mock = mockTranslations
//        mock.translations = ["data" : mock.translations!]
//        return mock
//    }
//
//    var testTranslations: Translations {
//        return manager.translations()
//    }
//
//    var mockBundle: BundleMock {
//        let path = fileManagerMock.urls(for: .cachesDirectory, in: .userDomainMask)[0].absoluteString
//        return BundleMock(path: path.replacingOccurrences(of: "file://", with: ""))!
//    }
//
//    var invalidTranslationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/InvalidTranslations.json"
//    }
//    
//    var emptyTranslationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/EmptyTranslations.json"
//    }
//
//    var emptyLanguageMetaTranslationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/EmptyLanguageMetaTranslations.json"
//    }
//    
//    var wrongFormatJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/WrongTypeTranslations.json"
//    }
//
//    var backendSelectedTranslationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/BackendSelectedLanguageTranslations.json"
//    }
//    
//
//    // MARK: - Test Case Lifecycle -
//
//    override func setUp() {
//        super.setUp()
//        print()
//
//        logger = ConsoleLogger()
//        logger.logLevel = .verbose
//        repositoryMock = TranslationsRepositoryMock()
//        fileManagerMock = FileManagerMock()
//        manager = TranslationManager(translationsType: Translations.self,
//                                     repository: repositoryMock,
//                                     logger: logger,
//                                     store: store,
//                                     fileManager: fileManagerMock)
//    }
//
//    override func tearDown() {
//        super.tearDown()
//
//        // Stop logger logging before teardown
//        logger.logLevel = .none
//
//        manager.clearTranslations(includingPersisted: true)
//        manager = nil
//        repositoryMock = nil
//        fileManagerMock = nil
//        store.clearAllData(true)
//
//        // To separate test cases in output
//        print("-----------")
//        print()
//    }
//
//    // MARK: - Loading -
//    
//    func testLoadTranslations() {
//        XCTAssertNil(manager.translationsObject)
//        manager.loadTranslations()
//        XCTAssertNotNil(manager.translationsObject,
//                        "Translations object shouldn't be nil after loading.")
//    }
//    
//    // MARK: - Update -
//    
//    func testUpdateSuccess() {
//        repositoryMock.translationsResponse = mockWrappedTranslations
//        XCTAssertNil(manager.synchronousUpdateTranslations(), "Error should be nil.")
//        XCTAssertNotNil(manager.translationsObject,
//                        "Translations should be loaded after successful update.")
//        XCTAssertNotNil(manager.persistedTranslations,
//                        "Persistent translations should be saved after successful update.")
//    }
//    
//    func testUpdateFailure() {
//        repositoryMock.translationsResponse = nil
//        XCTAssertNotNil(manager.synchronousUpdateTranslations(), "Error shouldn't be nil.")
//        XCTAssertNil(manager.translationsObject,
//                     "Translations should not be loaded after failed update.")
//        XCTAssertNil(manager.persistedTranslations,
//                     "Persistent translations should not be saved after failed update.")
//    }
//    
//    // MARK: - Translation for key
//    
//    func testTranslationForKeyFailure() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertNotEqual(manager.translationString(keyPath: "default.successKey"), "NoSuccess")
//    }
//    
//    func testTranslationForWrongKeyFailure() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertNil(manager.translationString(keyPath: "wrong.successKey"))
//    }
//    
//    func testTranslationForKeySuccess() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertEqual(manager.translationString(keyPath: "default.successKey"), "Fedt")
//    }
//    
//    func testTranslationForEmptyKey() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertNil(manager.translationString(keyPath: ""))
//    }
//    
//    // MARK: - Fetch -
//    
//    func testFetchCurrentLanguageSuccess() {
//        repositoryMock.currentLanguage = mockLanguage
//        let exp = expectation(description: "Fetch language should return one language.")
//        manager.fetchCurrentLanguage { (response) in
//            if case let .success(lang) = response.result {
//                XCTAssertEqual(lang.name, self.mockLanguage.name)
//            } else {
//                XCTAssert(false)
//            }
//            
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testFetchCurrentLanguageFailure() {
//        repositoryMock.currentLanguage = nil
//        let exp = expectation(description: "Fetch language should fail without language.")
//        manager.fetchCurrentLanguage { (response) in
//            if case .success(_) = response.result {
//                XCTAssert(false)
//            }
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testFetchAvailableLanguagesSuccess() {
//        repositoryMock.availableLanguages = [
//            Language(id: 0, name: "English", locale: "en-GB",
//                     direction: "LRM", acceptLanguage: "en-GB"),
//            Language(id: 1, name: "Danish", locale: "da-DK",
//                     direction: "LRM", acceptLanguage: "da-DK")
//        ]
//        
//        let exp = expectation(description: "Fetch available should return two languages.")
//        manager.fetchAvailableLanguages { (response) in
//            if case .failure(_) = response.result {
//                XCTAssert(false)
//            }
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testFetchAvailableLanguagesFailure() {
//        repositoryMock.availableLanguages = nil
//        let exp = expectation(description: "Fetch available should fail without languages.")
//        manager.fetchAvailableLanguages { (response) in
//            if case .success(_) = response.result {
//                XCTAssert(false)
//            }
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    // MARK: - Accept -
//    
//    func testAcceptLanguage() {
//        // Test simple language
//        repositoryMock.preferredLanguages = ["en"]
//        XCTAssertEqual(manager.acceptLanguage, "en;q=1.0")
//        
//        // Test two languages with locale
//        repositoryMock.preferredLanguages = ["da-DK", "en-GB"]
//        XCTAssertEqual(manager.acceptLanguage, "da-DK;q=1.0,en-GB;q=0.9")
//        
//        // Test max lang limit
//        repositoryMock.preferredLanguages = ["da-DK", "en-GB", "en", "cs-CZ", "sk-SK", "no-NO"]
//        XCTAssertEqual(manager.acceptLanguage,
//                       "da-DK;q=1.0,en-GB;q=0.9,en;q=0.8,cs-CZ;q=0.7,sk-SK;q=0.6",
//                       "There should be maximum 5 accept languages.")
//        
//        // Test fallback
//        repositoryMock.preferredLanguages = []
//        XCTAssertEqual(manager.acceptLanguage, "en;q=1.0",
//                       "If no accept language there should be fallback to english.")
//    }
//    
//    func testLastAcceptHeader() {
//        XCTAssertNil(manager.lastAcceptHeader, "Last accept header should be nil at start.")
//        manager.lastAcceptHeader = "da-DK;q=1.0,en;q=1.0"
//        XCTAssertEqual(manager.lastAcceptHeader, "da-DK;q=1.0,en;q=1.0")
//        manager.lastAcceptHeader = nil
//        XCTAssertNil(manager.lastAcceptHeader, "Last accept header should be nil.")
//    }
//    
//    // MARK: - Language Override -
//    
//    func testLanguageOverride() {
//        XCTAssertEqual(testTranslations.defaultSection.successKey, "Success")
//        manager.languageOverride = mockLanguage
//        XCTAssertEqual(testTranslations.defaultSection.successKey, "Fedt")
//    }
//    
//    func testLanguageOverrideStore() {
//        XCTAssertNil(manager.languageOverride, "Language override should be nil at start.")
//        manager.languageOverride = mockLanguage
//        XCTAssertNotNil(manager.languageOverride)
//        manager.languageOverride = nil
//        XCTAssertNil(manager.languageOverride, "Language override should be nil.")
//    }
//    
//    func testLanguageOverrideClearTranslations() {
//        // Load translations
//        manager.loadTranslations()
//        XCTAssertNotNil(manager.translationsObject,
//                        "Translations shouldn't be nil after loading.")
//        
//        // Override lang, should clear all loaded
//        manager.languageOverride = mockLanguage
//        XCTAssertNil(manager.translationsObject,
//                     "Translations should be cleared if language is overriden.")
//        
//        // Accessing again should load with override lang
//        _ = manager.translations() as Translations
//        XCTAssertNotNil(manager.translationsObject,
//                        "Translations should load with language override.")
//    }
//
//    func testBackendLanguagePriority() {
//        // We request da-DK as preferred language, which is not a part of the translations we get.
//        // The manager then should prioritise falling back to the language that the backend provided.
//        // Instead of falling to any type of english or first in the array.
//        //
//        // In the JSON backends return US english as most appropriate.
//        manager.clearTranslations(includingPersisted: true)
//        repositoryMock.preferredLanguages = ["da-DK"]
//        mockBundle.resourcePathOverride = backendSelectedTranslationsJSONPath
//        repositoryMock.customBundles = [mockBundle]
//        XCTAssertEqual(testTranslations.defaultSection.successKey, "Whatever")
//    }
//    
//    // MARK: - Translations -
//    
//    func testTranslationsMemoryCache() {
//        XCTAssertNil(manager.translationsObject)
//        XCTAssertEqual(testTranslations.defaultSection.successKey, "Success")
//        XCTAssertNotNil(manager.translationsObject)
//        XCTAssertEqual(testTranslations.defaultSection.successKey, "Success")
//    }
//    
//    // MARK: - Translation Dictionaries -
//    
//    func testPersistedTranslations() {
//        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil at start.")
//        manager.persistedTranslations = mockTranslations.translations
//        XCTAssertNotNil(manager.persistedTranslations)
//        manager.persistedTranslations = nil
//        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil.")
//    }
//    
//    func testPersistedTranslationsSaveFailure() {
//        fileManagerMock.searchPathUrlsOverride = []
//        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil at start.")
//        manager.persistedTranslations = mockTranslations.translations
//        XCTAssertNil(manager.persistedTranslations, "There shouldn't be any saved translations.")
//    }
//    
//    func testPersistedTranslationsSaveFailureBadUrl() {
//        fileManagerMock.searchPathUrlsOverride = [URL(string: "test://")!]
//        XCTAssertNil(manager.persistedTranslations, "Persisted translations should be nil at start.")
//        manager.persistedTranslations = mockTranslations.translations
//        XCTAssertNil(manager.persistedTranslations, "There shouldn't be any saved translations.")
//    }
//    
//    func testPersistedTranslationsOnUpdate() {
//        repositoryMock.translationsResponse = mockWrappedTranslations
//        XCTAssertNil(manager.synchronousUpdateTranslations(), "No error should happen on update.")
//        XCTAssertNotNil(manager.persistedTranslations, "Persisted translations should be available.")
//    }
//    
//    func testFallbackTranslations() {
//        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should be available.")
//    }
//    
//    func testFallbackTranslationsInvalidPath() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = "file://BlaBlaBla.json" // invalid path
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should fail with invalid path.")
//    }
//    
//    func testFallbackTranslationsInvalidJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = invalidTranslationsJSONPath // invalid json file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should fail with invalid JSON.")
//    }
//    
//    func testFallbackTranslationsEmptyJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = emptyTranslationsJSONPath // empty json file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.loadTranslations(), "Fallback translations should fail with invalid JSON.")
//    }
//    
//    func testFallbackTranslationsEmptyLanguageJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = emptyLanguageMetaTranslationsJSONPath// empty meta laguage file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.loadTranslations(), "Fallback translations should fail with empty language meta JSON.")
//    }
//    
//    func testFallbackTranslationsWrongFormatJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = wrongFormatJSONPath // wrong format json file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.fallbackTranslations, "Fallback translations should fail with wrong format JSON.")
//    }
//    
//    // MARK: - Unwrap & Parse -
//    
//    func testUnwrapAndParse() {
//        repositoryMock.preferredLanguages = ["en"]
//        let final = manager.processAllTranslations(mockWrappedTranslations.translations!)
//        XCTAssertNotNil(final, "Unwrap and parse should succeed.")
//        XCTAssertEqual(final?.value(forKeyPath: "default.successKey") as? String, Optional("SuccessUpdated"))
//    }
//    
//    // MARK: - Extraction -
//    
//    func testExtractWithFullLocale() {
//        repositoryMock.preferredLanguages = ["en-GB", "da-DK"]
//        let lang: NSDictionary = ["en-GB" : ["correct" : "yes"],
//                                  "da-DK" : ["correct" : "no"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractWithShortLocale() {
//        repositoryMock.preferredLanguages = ["da"]
//        let lang: NSDictionary = ["da-DK" : ["correct" : "yes"],
//                                  "en-GB" : ["correct" : "no"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractWithLanguageOverride() {
//        repositoryMock.preferredLanguages = ["en-GB", "en"]
//        manager.languageOverride = mockLanguage
//        let lang: NSDictionary = ["en-GB" : ["correct" : "no"],
//                                  "da-DK" : ["correct" : "yes"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractWithWrongLanguageOverride() {
//        repositoryMock.preferredLanguages = ["en-GB", "en"]
//        manager.languageOverride = mockLanguage
//        let lang: NSDictionary = ["en" : ["correct" : "yes"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractWithSameRegionsWithCurrentLanguage() {
//        repositoryMock.preferredLanguages = ["da-DK", "en-DK"]
//        manager.languageOverride = Language(id: 0, name: "English", locale: "en-UK",
//                                           direction: "lrm", acceptLanguage: "en-UK")
//        let lang: NSDictionary = ["en-AU" : ["correct" : "no"],
//                                  "en-UK" : ["correct" : "yes"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractWithNoLocaleButWithCurrentLanguage() {
//        repositoryMock.preferredLanguages = []
//        manager.languageOverride = mockLanguage
//        let lang: NSDictionary = ["en-GB" : ["correct" : "no"],
//                                  "da-DK" : ["correct" : "yes"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractWithNoLocaleAndNoCurrentLanguage() {
//        repositoryMock.preferredLanguages = []
//        let lang: NSDictionary = ["en-GB" : ["correct" : "yes"],
//                                  "da-DK" : ["correct" : "no"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
////        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("no"))
//    }
//    
//    func testExtractWithNoLocaleAndNoEnglish() {
//        repositoryMock.preferredLanguages = []
//        let lang: NSDictionary = ["es" : ["correct" : "no"],
//                                  "da-DK" : ["correct" : "yes"]]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.value(forKey: "correct") as? String, Optional("yes"))
//    }
//    
//    func testExtractFailure() {
//        repositoryMock.preferredLanguages = ["da-DK"]
//        let lang: NSDictionary = [:]
//        let dict = manager.extractLanguageDictionary(fromDictionary: lang)
//        XCTAssertNotNil(dict)
//        XCTAssertEqual(dict.allKeys.count, 0, "Extracted dictionary should not be empty.")
//    }
//    
//    // MARK: - Clearing -
//    
//    func testClearTranslations() {
//        manager.loadTranslations()
//        XCTAssertNotNil(manager.translationsObject, "Translations shouldn't be nil.")
//        manager.clearTranslations()
//        XCTAssertNil(manager.translationsObject, "Translations should not exist after clear.")
//    }
//    
//    func testClearPersistedTranslations() {
//        repositoryMock.translationsResponse = mockWrappedTranslations
//        XCTAssertNil(manager.synchronousUpdateTranslations())
//        XCTAssertNotNil(manager.persistedTranslations, "Persisted translations should exist.")
//        manager.clearTranslations(includingPersisted: true)
//        XCTAssertNil(manager.persistedTranslations, "Persisted translations should not exist after clear.")
//    }
//}
//
//// MARK: - Helpers -
//
//extension TranslationManager {
//    fileprivate func synchronousUpdateTranslations() -> NStackError.Translations? {
//        let semaphore = DispatchSemaphore(value: 0)
//        var error: NStackError.Translations?
//        
//        updateTranslations { e in
//            error = e
//            semaphore.signal()
//        }
//        semaphore.wait()
//        
//        return error
//    }
//}
