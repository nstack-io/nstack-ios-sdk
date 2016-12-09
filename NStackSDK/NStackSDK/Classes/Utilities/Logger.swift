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

protocol LoggerType {
    var logLevel: LogLevel { get set }
    func log(_ items: Any..., level: LogLevel)
}

class Logger: LoggerType {

    var logLevel: LogLevel = .error

    func log(_ items: Any..., level: LogLevel) {
        guard level.rawValue <= logLevel.rawValue else { return }
        print("[NStackSDK]", " ", level.message, " ", items)
    }
}
