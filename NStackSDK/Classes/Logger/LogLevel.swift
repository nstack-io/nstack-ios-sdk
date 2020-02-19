//
//  LogLevel.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 12/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case verbose = 0
    case warning = 1
    case error = 2
    case none = 3

    var message: String {
        switch self {
        case .verbose: return "#verbose:"
        case .warning: return "#warning:"
        case .error: return "#error:"
        case .none: return ""
        }
    }
}

extension LogLevel: Comparable {
    // swiftlint:disable:next all
    static public func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
