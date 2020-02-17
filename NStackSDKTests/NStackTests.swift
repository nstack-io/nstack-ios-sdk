//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import XCTest
@testable import NStackSDK

let testConfiguration: () -> Configuration = {
    var conf = Configuration(plistName: "NStack", environment: .debug, translationsClass: Translations.self)
    conf.verboseMode = true
    conf.updateOptions = [.onDidBecomeActive]
    conf.versionOverride = "2.0"
    conf.useMock = true
    return conf
}

class NStackTests: XCTestCase {

    override func setUp() {
        super.setUp()
        NStack.start(configuration: testConfiguration(), launchOptions: nil)
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Configuration
    func testConfigured() {
        XCTAssertTrue(NStack.sharedInstance.configured, "NStack should be configured after calling start.")
    }

    func testUpdateAppOpen() {
        NStack.sharedInstance.update()
        XCTAssertNotNil(NStack.sharedInstance.translationsManager?.bestFitLanguage, "Nstack should send the localizations to Translation Manager where that sets the best fit language.")
    }

    func testGetTranslation() {
        NStack.sharedInstance.update { (_) in
            do {
                guard let result = try NStack.sharedInstance.translationsManager?.translations() as? Translations else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(result.defaultSection.successKey, "SuccessUpdated")
            } catch {
                XCTFail()
            }
        }
    }

    // MARK: - Geography

    func testIPAddress() {
        let exp = expectation(description: "IP-address returned")
        NStack.sharedInstance.geographyManager?.ipDetails { (result) in
            switch result {
            case .success(let ipAddress):
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }
    func testUpdateCountriesList() {
        let exp = expectation(description: "Cached list of contries updated")
        NStack.sharedInstance.geographyManager?.updateCountries { (result) in
            switch result {
            case .success(let countriesArray):
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Validation
    func testValidEmail() {
        let exp = expectation(description: "Valid email")
        NStack.sharedInstance.validationManager?.validateEmail("chgr@nodes.dk") { (valid, _) in
            if valid {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Content

    func testContentResponseId() {
        let exp = expectation(description: "Content recieved")
        var completion: Completion<Int> = { (response) in
            switch response {
            case .success:
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }
        NStack.sharedInstance.contentManager?.getContentResponse("sdf", completion: completion)
        waitForExpectations(timeout: 5.0)
    }

    func testCollectionValid() {
        let exp = expectation(description: "Collection received")
        var completion: Completion<Int> = { (response) in
            switch response {
            case .success:
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }
        NStack.sharedInstance.contentManager?.fetchCollectionResponse(for: 24, completion: completion)
        waitForExpectations(timeout: 5.0)
    }

    func testFeedback() {
        let exp = expectation(description: "Feedback Posted")
        let completion: Completion<Any> = { (response) in
            switch response {
            case .success:
                exp.fulfill()
            case .failure:
                XCTFail("Failed to post feedback")
            }
        }
        NStack.sharedInstance.feedbackManager?.postFeedback("Testing Feedback", completion: completion)
        waitForExpectations(timeout: 5.0)
    }
}
