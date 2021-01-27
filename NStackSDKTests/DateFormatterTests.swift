//
//  DateFormatterTests.swift
//  NStackSDK
//
//  Created by Tiago Bras on 27/01/2021.
//  Copyright © 2021 Nodes ApS. All rights reserved.
//

import XCTest
@testable import NStackSDK

class DateFormatterTests: XCTestCase {

    func testISO8061DateFormatter() throws {
        let expectedDate = Date(timeIntervalSince1970: 1611749050)
        
        if #available(iOS 10.0, OSX 10.12, *) {
            XCTAssertEqual(DateFormatter.iso8601.date(from: "2021-01-27T12:04:10Z"), expectedDate)
            XCTAssertEqual(DateFormatter.iso8601.date(from: "2021-01-27T13:04:10+01:00"), expectedDate)
            XCTAssertNil(DateFormatter.iso8601.date(from: "2021-01T13:04:10-41:00"))
        }
        
        XCTAssertEqual(DateFormatter.iso8601Fallback.date(from: "2021-01-27T12:04:10Z"), expectedDate)
        XCTAssertEqual(DateFormatter.iso8601Fallback.date(from: "2021-01-27T13:04:10+01:00"), expectedDate)
        XCTAssertNil(DateFormatter.iso8601Fallback.date(from: "2021-01T13:04:10-41:00"))
    }

}
