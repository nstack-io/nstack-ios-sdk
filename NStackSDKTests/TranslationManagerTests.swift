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

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//    func testTranslationUpdate() {
//
//    }

    func testTranslations() {

        TranslationManager.sharedInstance.lastFetchedLanguage = nil
        TranslationManager.sharedInstance.languageOverride = Language(id: 11, name: "English (UK)", locale: "en-GB", direction: "LRM", data: NSDictionary())

        XCTAssertEqual(tr.defaultSection.successKey, "Success", "defaultSection.successKey does not have expected content in fallback!")

        let expected = expectation(description: "testFetchTranslations")

        TranslationManager.sharedInstance.fetchAvailableLanguages { (response) -> Void in
            switch response.result {
            case .success(let languages):
                XCTAssert(languages.count > 0, "No languages available")
                guard let danishLang = languages.filter({$0.locale == "da-DK"}).first else { XCTAssert(false, "Danish language not found"); return }
                TranslationManager.sharedInstance.languageOverride = danishLang
                TranslationManager.sharedInstance.updateTranslations { (error) -> Void in
                    print(tr.defaultSection.successKey)
                    XCTAssertEqual(tr.defaultSection.successKey,
                        "DET VAR EN SUCCESS",
                        "defaultSection.successKey does not have expected content in response from API!")
                    expected.fulfill()
                }

            case .failure(let error):
                XCTAssert(false, "Fetching languages failed - \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
    
}
