//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import XCTest
import Serializable
import Alamofire
@testable import NStackSDK

let testConfiguration: () -> Configuration = {
    var conf = Configuration(plistName: "NStack", translationsClass: Translations.self)
    conf.verboseMode = true
    conf.updateOptions = []
    conf.versionOverride = "2.0"
    return conf
}

class NStackTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testStart() {
        NStack.start(configuration: testConfiguration(), launchOptions: nil)
        XCTAssertTrue(NStack.sharedInstance.configured, "NStack should be configured after calling start.")
    }

    func testUpdate() {
        let expectation = expectationWithDescription("NStack update should succeed.")

        NStack.sharedInstance.update { (error) in
            XCTAssertNil(error, "NStack shouldn't error on update. \(error!.description)")
            if error == nil {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
