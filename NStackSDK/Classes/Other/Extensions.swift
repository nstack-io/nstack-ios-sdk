//
//  Extensions.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 12/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

extension FileManager {
    var documentsDirectory: URL? {
        return urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

extension String {
    func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime])
}

extension Date {
    var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }
}
