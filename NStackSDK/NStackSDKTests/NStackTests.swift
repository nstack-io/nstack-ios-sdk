//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import XCTest
import LocalizationManager
@testable import NStackSDK

let testConfiguration: () -> Configuration = {
    var conf = Configuration(plistName: "NStack", environment: .debug, localizationClass: Localization.self)
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

    func testLogsErrorWhenAlreadyConfigured() {
        XCTAssertEqual(NStack.sharedInstance.configuration.appId, "5dSr0geJis6PSTpABBR6zfwGbGZDJ2rJZW90")
        var conf = Configuration(plistName: "BadNStack", environment: .debug, localizationClass: Localization.self)
        conf.verboseMode = true
        conf.updateOptions = [.onDidBecomeActive]
        conf.versionOverride = "2.0"
        conf.useMock = true
        NStack.start(configuration: conf, launchOptions: nil)
        XCTAssertEqual(NStack.sharedInstance.configuration.appId, "5dSr0geJis6PSTpABBR6zfwGbGZDJ2rJZW90")
    }

    func testUpdateAppOpen() {
        NStack.sharedInstance.update()
        XCTAssertNotNil(NStack.sharedInstance.localizationManager?.bestFitLanguage, "Nstack should send the localizations to Localization Manager where that sets the best fit language.")
    }

    func testUpdateAppOpenFail() {
        if let mockRepo = NStack.sharedInstance.repository as? MockConnectionManager {
            mockRepo.succeed = false
        }
        let exp = expectation(description: "error returned")
        NStack.sharedInstance.update { (error) in
            if let err = error {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    func testGetTranslation() {
        NStack.sharedInstance.update { (_) in
            do {
                guard let result = try NStack.sharedInstance.localizationManager?.localization() as? Localization else {
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
        guard let country: Country =  NStack.sharedInstance.geographyManager?.countries?.first else {
            XCTFail("Country should be set")
            return
        }
        XCTAssertEqual(country.name, "TestCountry")
    }

    func testUpdateContinentsList() {
        let exp = expectation(description: "Cached list of continents updated")
        NStack.sharedInstance.geographyManager?.updateContinents { (result) in
            switch result {
            case .success(let countriesArray):
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
        guard let continent =  NStack.sharedInstance.geographyManager?.continents?.first else {
            XCTFail("continent should be set")
            return
        }
        XCTAssertEqual(continent.name, "TestContinent")
    }

    func testUpdateLanguagesList() {
        let exp = expectation(description: "Cached list of languages updated")
        NStack.sharedInstance.geographyManager?.updateLanguages { (result) in
            switch result {
            case .success(let countriesArray):
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
        guard let lang: DefaultLanguage =  NStack.sharedInstance.geographyManager?.languages?.first else {
            XCTFail("language should be set")
            return
        }
        XCTAssertEqual(lang.name, "TestLanguage")
    }

    func testUpdateTimezonesList() {
        let exp = expectation(description: "Cached list of timezones updated")
        NStack.sharedInstance.geographyManager?.updateTimezones { (_, _) in
            exp.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        guard let timezone: Timezone =  NStack.sharedInstance.geographyManager?.timezones?.first else {
            XCTFail("timezone should be set")
            return
        }
        XCTAssertEqual(timezone.name, "TestTimeZone")
    }

    func testFetchTimezone() {
        let exp = expectation(description: "Timezone fetched")
        NStack.sharedInstance.geographyManager?.timezone(lat: 12.234, lng: 13.345, completion: { (result) in
            switch result {
            case .success(let timezone):
                XCTAssertEqual(timezone.name, "TestTimeZone")
                exp.fulfill()
            case .failure:
                XCTFail("timezone should be returned")
            }
        })
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

    func testStoreProposal() {
        let exp = expectation(description: "Proposal stored")
        let localizationIdentifier = LocalizationItemIdentifier(section: "section", key: "key")
        NStack.sharedInstance.storeProposal(for: localizationIdentifier, with: "new_value") { (error) in
            if error == nil {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }

    func testStoreProposalFail() {
        if let mockRepo = NStack.sharedInstance.repository as? MockConnectionManager {
            mockRepo.succeed = false
        }
        let exp = expectation(description: "Proposal stored")
        let localizationIdentifier = LocalizationItemIdentifier(section: "section", key: "key")
        NStack.sharedInstance.storeProposal(for: localizationIdentifier, with: "new_value") { (error) in
            if error != nil {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }

//    func testUpdateAlert() {
//        XCTAssertFalse(NStack.sharedInstance.alertManager.alreadyShowingAlert)
//        if let mockRepo = NStack.sharedInstance.repository as? MockConnectionManager {
//            mockRepo.succeed = true
//            let version = Update.Version(state: .remind, lastId: 12, version: "1.2.4", localizations: .init(title: "Update", message: "Update now", positiveBtn: "OK", negativeBtn: "No"), link: nil)
//            mockRepo.appOpenData = AppOpenData(count: 59,
//                                               message: nil,
//                                               update: Update(newInThisVersion: Update.Changelog(state: true, lastId: 12, version: "1.2.3", localizations: nil), newerVersion: version),
//                                               rateReminder: nil,
//                                               localize: [
//                                                LocalizationConfig(lastUpdatedAt: Date(),
//                                                                   localeIdentifier: "en-GB",
//                                                                   shouldUpdate: true,
//                                                                   url: "locazlize.56.url",
//                                                                   language: DefaultLanguage(id: 56, name: "English", direction: "LRM", locale: Locale(identifier: "en-GB"), isDefault: true, isBestFit: true))
//                ],
//                                               platform: "ios",
//                                               createdAt: "2019-06-21T14:10:29+00:00",
//                                               lastUpdated: "2019-06-21T14:10:29+00:00")
//        } else {
//            XCTFail("Should be using mock repo")
//        }
//        let exp = expectation(description: "alert shown")
//        NStack.sharedInstance.update { (error) in
//            if let err = error {
//                XCTFail()
//            } else {
//
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//        DispatchQueue.main.async {
//            XCTAssertTrue(NStack.sharedInstance.alertManager.alreadyShowingAlert)
//        }
//    }

    func testISODateFormat() {
        let date = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(date.iso8601, "1970-01-01T00:00:00Z")
    }

}
