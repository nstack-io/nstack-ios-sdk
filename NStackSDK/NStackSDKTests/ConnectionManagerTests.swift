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

    var connectionManager: ConnectionManager!

    override func setUp() {
        super.setUp()
        connectionManager = ConnectionManager(configuration: connectionManagerConfig)
    }

    override func tearDown() {
        super.tearDown()
        connectionManager = nil
    }

    // TODO: Write tests
}
