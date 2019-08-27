////
////  LocalizationManagerTests.swift
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
//class LocalizationManagerTests: XCTestCase {
//
//    let store = NOPersistentStore.cache(withId: "LocalizationManagerTests")!
//    var repositoryMock: LocalizationsRepositoryMock!
//    var fileManagerMock: FileManagerMock!
//    var manager: LocalizationManager!
//    var logger: LoggerType!
//
//    let mockLanguage = Language(id: 0, name: "Danish", locale: "da-DK",
//                                direction: "lrm", acceptLanguage: "da-DK")
//
//    var mockLocalizations: LocalizationsResponse {
//        return LocalizationsResponse(localizations:
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
//    var mockWrappedLocalizations: LocalizationsResponse {
//        var mock = mockLocalizations
//        mock.localizations = ["data" : mock.localizations!]
//        return mock
//    }
//
//    var testLocalizations: Localizations {
//        return manager.localizations()
//    }
//
//    var mockBundle: BundleMock {
//        let path = fileManagerMock.urls(for: .cachesDirectory, in: .userDomainMask)[0].absoluteString
//        return BundleMock(path: path.replacingOccurrences(of: "file://", with: ""))!
//    }
//
//    var invalidLocalizationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/InvalidLocalizations.json"
//    }
//    
//    var emptyLocalizationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/EmptyLocalizations.json"
//    }
//
//    var emptyLanguageMetaLocalizationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/EmptyLanguageMetaLocalizations.json"
//    }
//    
//    var wrongFormatJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/WrongTypeLocalizations.json"
//    }
//
//    var backendSelectedLocalizationsJSONPath: String {
//        return Bundle(for: type(of: self)).resourcePath! + "/BackendSelectedLanguageLocalizations.json"
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
//        repositoryMock = LocalizationsRepositoryMock()
//        fileManagerMock = FileManagerMock()
//        manager = LocalizationManager(localizationsType: Localizations.self,
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
//        manager.clearLocalizations(includingPersisted: true)
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
//    func testLoadLocalizations() {
//        XCTAssertNil(manager.localizationsObject)
//        manager.loadLocalizations()
//        XCTAssertNotNil(manager.localizationsObject,
//                        "Localizations object shouldn't be nil after loading.")
//    }
//    
//    // MARK: - Update -
//    
//    func testUpdateSuccess() {
//        repositoryMock.localizationsResponse = mockWrappedLocalizations
//        XCTAssertNil(manager.synchronousUpdateLocalizations(), "Error should be nil.")
//        XCTAssertNotNil(manager.localizationsObject,
//                        "Localizations should be loaded after successful update.")
//        XCTAssertNotNil(manager.persistedLocalizations,
//                        "Persistent localizations should be saved after successful update.")
//    }
//    
//    func testUpdateFailure() {
//        repositoryMock.localizationsResponse = nil
//        XCTAssertNotNil(manager.synchronousUpdateLocalizations(), "Error shouldn't be nil.")
//        XCTAssertNil(manager.localizationsObject,
//                     "Localizations should not be loaded after failed update.")
//        XCTAssertNil(manager.persistedLocalizations,
//                     "Persistent localizations should not be saved after failed update.")
//    }
//    
//    // MARK: - Localization for key
//    
//    func testLocalizationForKeyFailure() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertNotEqual(manager.localizationString(keyPath: "default.successKey"), "NoSuccess")
//    }
//    
//    func testLocalizationForWrongKeyFailure() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertNil(manager.localizationString(keyPath: "wrong.successKey"))
//    }
//    
//    func testLocalizationForKeySuccess() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertEqual(manager.localizationString(keyPath: "default.successKey"), "Fedt")
//    }
//    
//    func testLocalizationForEmptyKey() {
//        repositoryMock.preferredLanguages = [mockLanguage.locale]
//        XCTAssertNil(manager.localizationString(keyPath: ""))
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
//        XCTAssertEqual(testLocalizations.defaultSection.successKey, "Success")
//        manager.languageOverride = mockLanguage
//        XCTAssertEqual(testLocalizations.defaultSection.successKey, "Fedt")
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
//    func testLanguageOverrideClearLocalizations() {
//        // Load localizations
//        manager.loadLocalizations()
//        XCTAssertNotNil(manager.localizationsObject,
//                        "Localizations shouldn't be nil after loading.")
//        
//        // Override lang, should clear all loaded
//        manager.languageOverride = mockLanguage
//        XCTAssertNil(manager.localizationsObject,
//                     "Localizations should be cleared if language is overriden.")
//        
//        // Accessing again should load with override lang
//        _ = manager.localizations() as Localizations
//        XCTAssertNotNil(manager.localizationsObject,
//                        "Localizations should load with language override.")
//    }
//
//    func testBackendLanguagePriority() {
//        // We request da-DK as preferred language, which is not a part of the localizations we get.
//        // The manager then should prioritise falling back to the language that the backend provided.
//        // Instead of falling to any type of english or first in the array.
//        //
//        // In the JSON backends return US english as most appropriate.
//        manager.clearLocalizations(includingPersisted: true)
//        repositoryMock.preferredLanguages = ["da-DK"]
//        mockBundle.resourcePathOverride = backendSelectedLocalizationsJSONPath
//        repositoryMock.customBundles = [mockBundle]
//        XCTAssertEqual(testLocalizations.defaultSection.successKey, "Whatever")
//    }
//    
//    // MARK: - Localizations -
//    
//    func testLocalizationsMemoryCache() {
//        XCTAssertNil(manager.localizationsObject)
//        XCTAssertEqual(testLocalizations.defaultSection.successKey, "Success")
//        XCTAssertNotNil(manager.localizationsObject)
//        XCTAssertEqual(testLocalizations.defaultSection.successKey, "Success")
//    }
//    
//    // MARK: - Localization Dictionaries -
//    
//    func testPersistedLocalizations() {
//        XCTAssertNil(manager.persistedLocalizations, "Persisted localizations should be nil at start.")
//        manager.persistedLocalizations = mockLocalizations.localizations
//        XCTAssertNotNil(manager.persistedLocalizations)
//        manager.persistedLocalizations = nil
//        XCTAssertNil(manager.persistedLocalizations, "Persisted localizations should be nil.")
//    }
//    
//    func testPersistedLocalizationsSaveFailure() {
//        fileManagerMock.searchPathUrlsOverride = []
//        XCTAssertNil(manager.persistedLocalizations, "Persisted localizations should be nil at start.")
//        manager.persistedLocalizations = mockLocalizations.localizations
//        XCTAssertNil(manager.persistedLocalizations, "There shouldn't be any saved localizations.")
//    }
//    
//    func testPersistedLocalizationsSaveFailureBadUrl() {
//        fileManagerMock.searchPathUrlsOverride = [URL(string: "test://")!]
//        XCTAssertNil(manager.persistedLocalizations, "Persisted localizations should be nil at start.")
//        manager.persistedLocalizations = mockLocalizations.localizations
//        XCTAssertNil(manager.persistedLocalizations, "There shouldn't be any saved localizations.")
//    }
//    
//    func testPersistedLocalizationsOnUpdate() {
//        repositoryMock.localizationsResponse = mockWrappedLocalizations
//        XCTAssertNil(manager.synchronousUpdateLocalizations(), "No error should happen on update.")
//        XCTAssertNotNil(manager.persistedLocalizations, "Persisted localizations should be available.")
//    }
//    
//    func testFallbackLocalizations() {
//        XCTAssertNotNil(manager.fallbackLocalizations, "Fallback localizations should be available.")
//    }
//    
//    func testFallbackLocalizationsInvalidPath() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = "file://BlaBlaBla.json" // invalid path
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.fallbackLocalizations, "Fallback localizations should fail with invalid path.")
//    }
//    
//    func testFallbackLocalizationsInvalidJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = invalidLocalizationsJSONPath // invalid json file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.fallbackLocalizations, "Fallback localizations should fail with invalid JSON.")
//    }
//    
//    func testFallbackLocalizationsEmptyJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = emptyLocalizationsJSONPath // empty json file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.loadLocalizations(), "Fallback localizations should fail with invalid JSON.")
//    }
//    
//    func testFallbackLocalizationsEmptyLanguageJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = emptyLanguageMetaLocalizationsJSONPath// empty meta laguage file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.loadLocalizations(), "Fallback localizations should fail with empty language meta JSON.")
//    }
//    
//    func testFallbackLocalizationsWrongFormatJSON() {
//        let bundle = mockBundle
//        bundle.resourcePathOverride = wrongFormatJSONPath // wrong format json file
//        repositoryMock.customBundles = [bundle]
//        XCTAssertNotNil(manager.fallbackLocalizations, "Fallback localizations should fail with wrong format JSON.")
//    }
//    
//    // MARK: - Unwrap & Parse -
//    
//    func testUnwrapAndParse() {
//        repositoryMock.preferredLanguages = ["en"]
//        let final = manager.processAllLocalizations(mockWrappedLocalizations.localizations!)
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
//    func testClearLocalizations() {
//        manager.loadLocalizations()
//        XCTAssertNotNil(manager.localizationsObject, "Localizations shouldn't be nil.")
//        manager.clearLocalizations()
//        XCTAssertNil(manager.localizationsObject, "Localizations should not exist after clear.")
//    }
//    
//    func testClearPersistedLocalizations() {
//        repositoryMock.localizationsResponse = mockWrappedLocalizations
//        XCTAssertNil(manager.synchronousUpdateLocalizations())
//        XCTAssertNotNil(manager.persistedLocalizations, "Persisted localizations should exist.")
//        manager.clearLocalizations(includingPersisted: true)
//        XCTAssertNil(manager.persistedLocalizations, "Persisted localizations should not exist after clear.")
//    }
//}
//
//// MARK: - Helpers -
//
//extension LocalizationManager {
//    fileprivate func synchronousUpdateLocalizations() -> NStackError.Localizations? {
//        let semaphore = DispatchSemaphore(value: 0)
//        var error: NStackError.Localizations?
//        
//        updateLocalizations { e in
//            error = e
//            semaphore.signal()
//        }
//        semaphore.wait()
//        
//        return error
//    }
//}
