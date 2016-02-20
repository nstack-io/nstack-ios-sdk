//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import XCTest
import Harbor
import Serializable
import Alamofire
@testable import NStack

class NStackTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        var conf = Configuration(plistName: "NStack", translationsClass: Translations.self)
        conf.verboseMode = true
        NStack.start(configuration: conf)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let expectation = expectationWithDescription("testOpen")
        
        NStack.update { (error) -> Void in
            XCTAssertNil(error, "Error: \(error)")
//            XCTAssertNotNil(data, "Data is nil")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testTranslations() {
        
        TranslationManager.sharedInstance.clearCachedTranslations()
        
        XCTAssert(tr.defaultSection.successKey == "Success", "defaultSection.successKey does not have expected content in fallback!")

        let expectation = expectationWithDescription("testFetchTranslations")
        
        TranslationManager.sharedInstance.fetchAvailableLanguages { (result) -> Void in
            switch result {
            case let .Success(data: languages):
                XCTAssert(languages.count > 0, "No languages available")
                guard let firstLang = languages.first else { return }
                TranslationManager.sharedInstance.languageOverride = firstLang
                TranslationManager.sharedInstance.updateTranslations { (error) -> Void in
                    XCTAssert(tr.defaultSection.successKey == "Success", "defaultSection.successKey does not have expected content in response from API!")
                    expectation.fulfill()
                }

            case .Error:
                XCTAssert(false, "Fetching languages failed!")
            }
        }
        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testUpdateManager() {
        
    }
    
    func testVersionUtils() {
        XCTAssertTrue(NStackVersionUtils.isVersion("1.0.1", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1 ", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1.  ", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0.0", greaterThanVersion: "1.0"))
        
        XCTAssertTrue(NStackVersionUtils.isVersion("1.0.1", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1 ", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1.  ", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0", greaterThanVersion: "1.1.2.1"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0.0", greaterThanVersion: "1.9.11111"))
        
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "1.0.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0 ", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.  ", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "2.0"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "2.0.0"))
        
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0", greaterThanVersion: "1.0.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0.  ", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.1.2.1", greaterThanVersion: "2.0"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.9.11111", greaterThanVersion: "2.0.0"))
    }
}
