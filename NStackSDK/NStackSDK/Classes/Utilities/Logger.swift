//
//  Logger.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
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

enum Logger {
    static var logLevel: LogLevel = .error

    static func log(_ items: Any..., level: LogLevel) {
        guard level.rawValue <= logLevel.rawValue else { return }
        print("[NStackSDK]", " ", level.message, " ", items)
    }
}

func log(_ items: Any..., level: LogLevel) {
    Logger.log(items, level: level)
}
