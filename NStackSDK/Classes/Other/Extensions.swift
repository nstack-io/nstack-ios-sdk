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

@available(iOSApplicationExtension 10.0, *)
extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    static let iso8601: Formatter = {
        if #available(iOSApplicationExtension 10.0, *) {
            return ISO8601DateFormatter([.withInternetDateTime])
        } else {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            return formatter
        }
    }()
}

extension Date {
    var iso8601: String {
        return DateFormatter.iso8601.string(for: self) ?? ""
    }
}
