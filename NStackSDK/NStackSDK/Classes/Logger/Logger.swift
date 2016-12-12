//
//  Logger.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

protocol LoggerType {
    var logLevel: LogLevel { get set }
    func writeLogEntry(_ items: [String], level: LogLevel,
                       file: StaticString, line: Int, function: StaticString)
}

extension LoggerType {
    func log(_ items: CustomStringConvertible...,
             level: LogLevel,
             file: StaticString = #file,
             line: Int = #line,
             function: StaticString = #function) {
        writeLogEntry(items.map({ $0.description }), level: level, file: file, line: line, function: function)
    }
}

class ConsoleLogger: LoggerType {

    var logLevel: LogLevel = .error

    func writeLogEntry(_ items: [String],
                       level: LogLevel,
                       file: StaticString,
                       line: Int,
                       function: StaticString) {
        guard level >= logLevel, logLevel != .none else { return }

        let message = items.joined(separator: " ")
        if logLevel == .verbose {
            print("[NStackSDK] \(level.message) \(file):\(line) – \(function) – \(message)")
        } else {
            print("[NStackSDK] \(level.message) \(message)")
        }
    }
}
