//
////
////  ConnectionManagerTests.swift
////  NStackSDK
////
////  Created by Dominik Hádl on 15/08/16.
////  Copyright © 2016 Nodes ApS. All rights reserved.
////
//
//import XCTest
//@testable import NStackSDK
//
//extension XCTestCase {
//    func expect(waitTime: TimeInterval, name: String, action: (XCTestExpectation) -> ()) {
//        let expected = expectation(description: name)
//        action(expected)
//        waitForExpectations(timeout: 10, handler: nil)
//    }
//}
//
//class ConnectionManagerTests: XCTestCase {
//
//    let connectionManagerConfig: APIConfiguration = {
//        let test = testConfiguration()
//        return APIConfiguration(appId: test.appId, restAPIKey: test.restAPIKey, isFlat: test.flat)
//    }()
//
//    var connectionManager: ConnectionManager!
//
//    override func setUp() {
//        super.setUp()
//        connectionManager = ConnectionManager(configuration: connectionManagerConfig)
//    }
//
//    override func tearDown() {
//        super.tearDown()
//        connectionManager = nil
//    }
//
//    func testInvalidateEmail() {
//        connectionManager.validateEmail("veryWrongEmail") { (result) in
//            
//            switch result {
//            case .success(let validated):
//                XCTAssertFalse(validated.ok)
//            case .failure(let fail):
//                XCTFail(fail.localizedDescription)
//            }
//        }
//    }
//    
//    func testValidateEmail() {
//        let exp = expectation(description: "Endpoint Succeeds")
//        
//        connectionManager.validateEmail("chgr@nodes.dk") { (result) in
//            switch result {
//            case .success(let valid):
//                if valid.ok {
//                    exp.fulfill()
//                } else {
//                   XCTFail()
//                }
//            case .failure(_):
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 5.0) { (_) -> Void in
//        }
//    }
//    
//    // TODO: Write more tests
//    
//}
