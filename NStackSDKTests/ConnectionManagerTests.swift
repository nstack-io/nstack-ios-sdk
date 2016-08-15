//
//  ConnectionManagerTests.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import XCTest
@testable import NStackSDK

class ConnectionManagerTests: XCTestCase {

    func testAppOpen() {
        let expectation = expectationWithDescription("App open call")

        ConnectionManager.postAppOpen(oldVersion: "1.0", currentVersion: "1.0") { (response) -> Void in
            switch response.result {
            case .Success(_):
                expectation.fulfill()
            case .Failure(let error):
                XCTAssertNil(error, "App Open call errored: \(error.localizedDescription).")
                XCTFail("App Open call was a failure.")
            }
        }

        waitForExpectationsWithTimeout(10, handler: nil)
    }
}
