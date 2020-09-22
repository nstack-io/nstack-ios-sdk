//
//  VersionUtilitiesTests.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import XCTest
@testable import NStackSDK

class VersionUtilitiesTests: XCTestCase {

    func testGreaterVersions() {
        XCTAssertTrue(VersionUtilities.isVersion("1.0.1", greaterThanVersion: "1.0"))
        XCTAssertTrue(VersionUtilities.isVersion("1.1", greaterThanVersion: "1.0"))
        XCTAssertTrue(VersionUtilities.isVersion("1.1 ", greaterThanVersion: "1.0"))
        XCTAssertTrue(VersionUtilities.isVersion("1.1.  ", greaterThanVersion: "1.0"))
        XCTAssertTrue(VersionUtilities.isVersion("2.0", greaterThanVersion: "1.0"))
        XCTAssertTrue(VersionUtilities.isVersion("2.0.0", greaterThanVersion: "1.0"))

        XCTAssertTrue(VersionUtilities.isVersion("1.0.1", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(VersionUtilities.isVersion("1.1", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(VersionUtilities.isVersion("1.1 ", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(VersionUtilities.isVersion("1.1.  ", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(VersionUtilities.isVersion("2.0", greaterThanVersion: "1.1.2.1"))
        XCTAssertTrue(VersionUtilities.isVersion("2.0.0", greaterThanVersion: "1.9.11111"))
    }

    func testLowerVersions() {
        XCTAssertFalse(VersionUtilities.isVersion("1.0", greaterThanVersion: "1.0.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0 ", greaterThanVersion: "1.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0.  ", greaterThanVersion: "1.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0", greaterThanVersion: "2.0"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0", greaterThanVersion: "2.0.0"))

        XCTAssertFalse(VersionUtilities.isVersion("1.0.0", greaterThanVersion: "1.0.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.0.0.  ", greaterThanVersion: "1.1"))
        XCTAssertFalse(VersionUtilities.isVersion("1.1.2.1", greaterThanVersion: "2.0"))
        XCTAssertFalse(VersionUtilities.isVersion("1.9.11111", greaterThanVersion: "2.0.0"))
    }
}
