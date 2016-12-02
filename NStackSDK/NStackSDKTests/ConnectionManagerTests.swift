//
//  ConnectionManagerTests.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import XCTest
@testable import NStackSDK

extension XCTestCase {
    func expect(waitTime: TimeInterval, name: String, action: (XCTestExpectation) -> ()) {
        let expected = expectation(description: name)
        action(expected)
        waitForExpectations(timeout: 10, handler: nil)
    }
}

class ConnectionManagerTests: XCTestCase {

    let connectionManagerConfig: APIConfiguration = {
        let test = testConfiguration()
        return APIConfiguration(appId: test.appId, restAPIKey: test.restAPIKey, isFlat: test.flat)
    }()

    override func setUp() {
        super.setUp()
        ConnectionManager.configuration = connectionManagerConfig
    }

    override func tearDown() {
        super.tearDown()
        ConnectionManager.configuration = APIConfiguration()
    }

    func testSomething() {
        let expected = expectation(description: "Something")
        
        DispatchQueue.main.async {
            sleep(1)
            expected.fulfill()
        }

        

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAppOpen() {
        expect(waitTime: 10, name: "App open call") { expectation in
            ConnectionManager.postAppOpen(oldVersion: "1.0", currentVersion: "1.0") { (response) -> Void in
                switch response.result {
                case .success(_):
                    expectation.fulfill()
                case .failure(let error):
                    XCTAssertNil(error, "App Open call errored: \(error.localizedDescription).")
                    XCTFail("App Open call was a failure.")
                }
            }
        }
    }

    func testTranslationsDownload() {
        expect(waitTime: 10, name: "Translations Download") { expectation in
            ConnectionManager.fetchTranslations { (response) in
                switch response.result {
                case .success(let data):
                    expectation.fulfill()

                    // TODO: Check if not flat
                    XCTAssertNotNil(data.translations, "Translations dictionary is empty.")
                    XCTAssertEqual(data.languageData?.language?.locale, "en-GB", "Default language should be en-GB.")

                case .failure(let error):
                    XCTAssertNil(error, "Translations download errored: \(error.localizedDescription).")
                    XCTFail("Translations download was a failure.")
                }
            }
        }
    }

    func testTranslationsFlatDownload() {
        ConnectionManager.configuration = APIConfiguration(appId: connectionManagerConfig.appId,
                                                           restAPIKey: connectionManagerConfig.restAPIKey,
                                                           isFlat: true)

        expect(waitTime: 10, name: "Translations Flat Download") { expectation in
            ConnectionManager.fetchTranslations { (response) in
                switch response.result {
                case .success(let data):
                    expectation.fulfill()

                    // TODO: Check if flat
                    XCTAssertNotNil(data.translations, "Translations dictionary is empty.")
                    XCTAssertEqual(data.languageData?.language?.locale, "en-GB", "Default language should be en-GB.")

                case .failure(let error):
                    XCTAssertNil(error, "Translations Flat download errored: \(error.localizedDescription).")
                    XCTFail("Translations Flat download was a failure.")
                }
            }
        }
    }

    func testCurrentLanguageDownload() {
        expect(waitTime: 10, name: "Current Language Download") { expectation in
            ConnectionManager.fetchCurrentLanguage { (response) in
                switch response.result {
                case .success(let language):
                    expectation.fulfill()
                    XCTAssertEqual(language.locale, "en-GB", "Default language should be en-GB.")
                case .failure(let error):
                    XCTAssertNil(error, "Current language download errored: \(error.localizedDescription).")
                    XCTFail("Current language download was a failure.")
                }
            }
        }
    }

    func testAvailableLanguagesDownload() {
        expect(waitTime: 10, name: "Available Languages Download") { expectation in
            ConnectionManager.fetchAvailableLanguages { (response) in
                switch response.result {
                case .success(let languages):
                    expectation.fulfill()
                    XCTAssertTrue(languages.count == 3, "There should be three languages available")
                    XCTAssertEqual(languages.first?.locale, "en-GB", "Default (first) language should be en-GB.")
                case .failure(let error):
                    XCTAssertNil(error, "Available Languages download errored: \(error.localizedDescription).")
                    XCTFail("Available Languages download was a failure.")
                }
            }
        }
    }

    func testUpdateInfoDonwnload() {
        expect(waitTime: 10, name: "Update Available Download") { expectation in
            ConnectionManager.fetchUpdates(oldVersion: "0.0", currentVersion: "0.1") { (response) in
                switch response.result {
                case .success(_):
                    expectation.fulfill()

//                    XCTAssertTrue(update, "There should be two languages available")
//                    XCTAssertEqual(languages.first?.locale, "en-GB", "Default (first) language should be en-GB.")
                case .failure(let error):
                    XCTAssertNil(error, "Update Available download errored: \(error.localizedDescription).")
                    XCTFail("Update Available download was a failure.")
                }
            }
        }
    }
}
