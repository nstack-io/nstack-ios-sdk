//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import XCTest
//import Serpent
//import Alamofire
@testable import NStackSDK

let testConfiguration: () -> Configuration = {
    var conf = Configuration(plistName: "NStack", translationsClass: Localizable.self)
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

    //This doesnt work because I cant figure out what model to give the TranslationManager to confirm to the LocalizableModel protocol
//    func testGetTranslation() {
//        NStack.sharedInstance.update()
//        do {
//            guard let result = try NStack.sharedInstance.translationsManager?.translation(for: "default.successKey") else {
//                XCTFail()
//                return
//            }
//            XCTAssertEqual(result, "SuccessUpdated")
//        }
//        catch {
//            XCTFail()
//        }
//    }

//    // MARK: - Geography
//
//    func testIPAddress() {
//        let exp = expectation(description: "IP-address returned")
//        NStack.sharedInstance.ipDetails { (ipAddress, _) in
//            if let _ = ipAddress {
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//    func testUpdateCountriesList() {
//        let exp = expectation(description: "Cached list of contries updated")
//        NStack.sharedInstance.updateCountries { (countries, error) in
//            if let cachedCountries = NStack.sharedInstance.countries, !cachedCountries.isEmpty, !countries.isEmpty {
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    // MARK: - Validation
//    func testValidEmail() {
//        let exp = expectation(description: "Valid email")
//        NStack.sharedInstance.validateEmail("chgr@nodes.dk") { (valid, error) in
//            if valid {
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testInvalidEmail() {
//        let exp = expectation(description: "Invalid email")
//        NStack.sharedInstance.validateEmail("veryWrongEmail") { (valid, error) in
//            if !valid {
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    // MARK: - Content
//
//    func testContentResponseId() {
//        let exp = expectation(description: "Content recieved")
//        NStack.sharedInstance.getContentResponse(60) { (response, error) in
//            //parse content
//            guard let dictionary = response as? NSDictionary,
//                let name = dictionary.object(forKey: "name") as? String,
//                name == "Africa" else {
//                XCTFail()
//                return
//            }
//            print("Africa: \(dictionary)")
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentResponseSlug() {
//        let exp = expectation(description: "Content recieved")
//        NStack.sharedInstance.getContentResponse("africacontinent") { (response, error) in
//            //parse content
//            guard let dictionary = response as? NSDictionary,
//                let name = dictionary.object(forKey: "name") as? String,
//                name == "Africa" else {
//                    XCTFail()
//                    return
//            }
//            print("Africa: \(dictionary)")
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentResponseObjectSlugStronglyTyped() {
//
//        struct Person: Swift.Codable {
//            var firstName: String
//            var lastName: String
//        }
//
//        let exp = expectation(description: "Content received")
//
//        let completion: (Result<Person>) -> Void = { result in
//            switch result {
//            case .success(let person):
//                print(person)
//                 exp.fulfill()
//            default:
//                 XCTFail()
//                break
//            }
//        }
//
//        NStack.sharedInstance.fetchStaticResponse(atSlug: "testObject", completion: completion)
//
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentResponseArraySlugStronglyTyped() {
//
//        struct Person: Swift.Codable {
//            var firstName: String
//            var lastName: String
//        }
//
//        let exp = expectation(description: "Content received")
//
//        let completion: (Result<[Person]>) -> Void = { result in
//            switch result {
//            case .success(let person):
//                print(person)
//                exp.fulfill()
//
//            default:
//                XCTFail()
//                break
//            }
//        }
//
//        NStack.sharedInstance.fetchStaticResponse(atSlug: "testarray", completion: completion)
//
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentResponseExtended() {
//        let exp = expectation(description: "Content recieved")
//        NStack.sharedInstance.getContentResponse(60, key: "name") { (response, error) in
//            if let name = response as? String, name == "Africa" {
//                print("Name is \(name)")
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentResponseWrongUnwrapper() {
//        let exp = expectation(description: "Content recieved")
//        NStack.sharedInstance.getContentResponse(60, { (dict, _) -> Any? in dict["wrongUnwrapper"]}) { (response, error) in
//            if let error = error as? NStackError.Manager {
//                switch error {
//                case .parsing(let reason):
//                    if reason == "No data found using the default or specified unwrapper" {
//                        exp.fulfill()
//                    } else {
//                        XCTFail()
//                    }
//                default:
//                    XCTFail()
//                }
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentResponseWrongKey() {
//        let exp = expectation(description: "Content recieved")
//        NStack.sharedInstance.getContentResponse(60, key: "noDataForKey") { (response, error) in
//            if let error = error as? NStackError.Manager {
//                switch error {
//                case .parsing(let reason):
//                    if reason == "No data found for specified key" {
//                        exp.fulfill()
//                    } else {
//                        XCTFail()
//                    }
//                default:
//                    XCTFail()
//                }
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentInvalidId() {
//        let exp = expectation(description: "Invalid id")
//        NStack.sharedInstance.getContentResponse(6029035) { (response, error) in
//            //parse content
//            if error != nil {
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testContentInvalidSlug() {
//        let exp = expectation(description: "Invalid slug")
//        NStack.sharedInstance.getContentResponse("invalidSlug") { (response, error) in
//            //parse content
//            if error != nil {
//                exp.fulfill()
//            } else {
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
//
//    func testCollectionValid() {
//
//        struct Country: Swift.Codable {
//            let name: String
//        }
//        let exp = expectation(description: "Collection received")
//        let completion: (Result<Country>) -> Void = { result in
//            switch result {
//            case .success(let country):
//                print(country)
//                exp.fulfill()
//            default:
//                XCTFail()
//                break
//            }
//        }
//
//        NStack.sharedInstance.fetchCollectionResponse(for: 24, completion: completion)
//
//        waitForExpectations(timeout: 5.0)
//    }
}
