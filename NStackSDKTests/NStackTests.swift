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
    var conf = Configuration(plistName: "NStack", environment: .debug, localizationClass: Translations.self)
    conf.verboseMode = true
    conf.updateOptions = [.onDidBecomeActive]
    conf.versionOverride = "2.0"
    conf.useMock = false
    return conf
}

class NStackTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        NStack.start(configuration: testConfiguration(), launchOptions: nil)
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Configuration
    func testConfigured() {
        XCTAssertTrue(NStack.sharedInstance.configured, "NStack should be configured after calling start.")
    }

    func testUpdateAppOpen() {
        let exp = expectation(description: "Best fit language was set")
        NStack.sharedInstance.update { _ in
            XCTAssertNotNil(NStack.sharedInstance.localizationManager?.bestFitLanguage, "Nstack should send the localizations to Translation Manager where that sets the best fit language.")
            exp.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }

    func testGetTranslation() {
        NStack.sharedInstance.update { (_) in
            do {
                guard let result = try NStack.sharedInstance.localizationManager?.localization() as? Translations else {
                    XCTFail("Translations were nil or coulsn't be cast to `Translations`")
                    return
                }
                XCTAssertEqual(result.defaultSection.successKey, "Success")
            } catch {
                XCTFail("Failed with error \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Geography

    func testIPAddress() {
        let exp = expectation(description: "IP-address returned")
        NStack.sharedInstance.geographyManager?.ipDetails { (result) in
            switch result {
            case .success:
                exp.fulfill()
            case .failure(let error):
                XCTFail("Failed with error \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    func testUpdateCountriesList() {
        let exp = expectation(description: "Cached list of contries updated")
        NStack.sharedInstance.geographyManager?.countries { (result) in
            switch result {
            case .success:
                exp.fulfill()
            case .failure(let error):
                XCTFail("Failed to fetch the countries: \(error.localizedDescription)")
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
                XCTFail("Email isn't valid")
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Content

    func testContentResponseId() {

        struct Name: Codable {
            let firstName: String
            let lastName: String
        }

        let exp = expectation(description: "Content recieved")
        let completion: Completion<[Name]> = { (response) in
            switch response {
            case .success:
                exp.fulfill()
            case .failure(let error):
                XCTFail("Failed with error \(error.localizedDescription)")
            }
        }
        NStack.sharedInstance.contentManager?.getContentResponse("testarray", completion: completion)
        waitForExpectations(timeout: 5.0)
    }

    func testCollectionValid() {

        struct Country: Codable {
            let id: Int
            let name: String
        }

        let exp = expectation(description: "Collection received")
        let completion: Completion<Country> = { (response) in
            switch response {
            case .success:
                exp.fulfill()
            case .failure(let error):
                XCTFail("Failed with error \(error.localizedDescription)")
            }
        }
        NStack.sharedInstance.contentManager?.fetchCollectionResponse(for: 24, completion: completion)
        waitForExpectations(timeout: 5.0)
    }

    #if canImport(UIKit)
    func testFeedbackImageUpload() {
        let exp = expectation(description: "Image upload")

        if let data = try? Data(contentsOf: Bundle(for: NStackTests.self).url(forResource: "bug_screenshot", withExtension: "jpeg")!) {
            let image = UIImage(data: data)!

            NStack.sharedInstance.feedbackManager?.provideFeedback(
                type: .bug,
                appVersion: "1.4",
                message: "Testing upload",
                image: image,
                completion: { (result) in
                    switch result {
                    case .success:
                        exp.fulfill()
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    }

            })
        }

        self.wait(for: [exp], timeout: 20)
    }
    #endif
}
