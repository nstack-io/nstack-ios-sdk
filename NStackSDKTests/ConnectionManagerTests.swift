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
    func expect(waitTime: NSTimeInterval, name: String, action: (XCTestExpectation) -> ()) {
        let expectation = expectationWithDescription(name)
        action(expectation)
        waitForExpectationsWithTimeout(10, handler: nil)
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
        let expectation = expectationWithDescription("Something")

        dispatch_async(dispatch_get_main_queue()) {
            sleep(1)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testAppOpen() {
        expect(10, name: "App open call") { expectation in
            ConnectionManager.postAppOpen(oldVersion: "1.0", currentVersion: "1.0") { (response) -> Void in
                switch response.result {
                case .Success(_):
                    expectation.fulfill()
                case .Failure(let error):
                    XCTAssertNil(error, "App Open call errored: \(error.localizedDescription).")
                    XCTFail("App Open call was a failure.")
                }
            }
        }
    }

    func testTranslationsDownload() {
        expect(10, name: "Translations Download") { expectation in
            ConnectionManager.fetchTranslations { (response) in
                switch response.result {
                case .Success(let data):
                    expectation.fulfill()

                    // TODO: Check if not flat
                    XCTAssertNotNil(data.translations, "Translations dictionary is empty.")
                    XCTAssertEqual(data.languageData?.language?.locale, "en-GB", "Default language should be en-GB.")

                case .Failure(let error):
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

        expect(10, name: "Translations Flat Download") { expectation in
            ConnectionManager.fetchTranslations { (response) in
                switch response.result {
                case .Success(let data):
                    expectation.fulfill()

                    // TODO: Check if flat
                    XCTAssertNotNil(data.translations, "Translations dictionary is empty.")
                    XCTAssertEqual(data.languageData?.language?.locale, "en-GB", "Default language should be en-GB.")

                case .Failure(let error):
                    XCTAssertNil(error, "Translations Flat download errored: \(error.localizedDescription).")
                    XCTFail("Translations Flat download was a failure.")
                }
            }
        }
    }

    func testCurrentLanguageDownload() {
        expect(10, name: "Current Language Download") { expectation in
            ConnectionManager.fetchCurrentLanguage { (response) in
                switch response.result {
                case .Success(let language):
                    expectation.fulfill()
                    XCTAssertEqual(language.locale, "en-GB", "Default language should be en-GB.")
                case .Failure(let error):
                    XCTAssertNil(error, "Current language download errored: \(error.localizedDescription).")
                    XCTFail("Current language download was a failure.")
                }
            }
        }
    }

    func testAvailableLanguagesDownload() {
        expect(10, name: "Available Languages Download") { expectation in
            ConnectionManager.fetchAvailableLanguages { (response) in
                switch response.result {
                case .Success(let languages):
                    expectation.fulfill()
                    XCTAssertTrue(languages.count == 2, "There should be two languages available")
                    XCTAssertEqual(languages.first?.locale, "en-GB", "Default (first) language should be en-GB.")
                case .Failure(let error):
                    XCTAssertNil(error, "Available Languages download errored: \(error.localizedDescription).")
                    XCTFail("Available Languages download was a failure.")
                }
            }
        }
    }

    func testUpdateInfoDonwnload() {
        expect(10, name: "Update Available Download") { expectation in
            ConnectionManager.fetchUpdates(oldVersion: "0.0", currentVersion: "0.1") { (response) in
                switch response.result {
                case .Success(let update):
                    expectation.fulfill()

//                    XCTAssertTrue(update, "There should be two languages available")
//                    XCTAssertEqual(languages.first?.locale, "en-GB", "Default (first) language should be en-GB.")
                case .Failure(let error):
                    XCTAssertNil(error, "Update Available download errored: \(error.localizedDescription).")
                    XCTFail("Update Available download was a failure.")
                }
            }
        }
    }
}
