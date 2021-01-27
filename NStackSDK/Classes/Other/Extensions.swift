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

@available(iOS 10.0, OSX 10.12, *)
extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    @available(iOS 10.0, OSX 10.12, *)
    static let iso8601: ISO8601DateFormatter = ISO8601DateFormatter([.withInternetDateTime])
    
    static let iso8601Fallback: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        if #available(iOS 10.0, OSX 10.12, *) {
            return DateFormatter.iso8601.string(from: self)
        } else {
            return DateFormatter.iso8601Fallback.string(from: self)
        }
    }
}
