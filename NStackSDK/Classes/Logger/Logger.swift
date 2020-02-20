//
//  Logger.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public protocol LoggerType: class {
    var logLevel: LogLevel { get set }
    var customName: String? { get set }
    var detailedOutput: Bool { get set }

    func writeLogEntry(_ items: [String], level: LogLevel,
                       file: StaticString, line: Int, function: StaticString)
}

extension LoggerType {

    func log(_ items: CustomStringConvertible...,
             level: LogLevel,
             file: StaticString = #file,
             line: Int = #line,
             function: StaticString = #function) {
        writeLogEntry(items.map({ $0.description }), level: level,
                      file: file, line: line, function: function)
    }

    func logVerbose(_ items: CustomStringConvertible...,
                    file: StaticString = #file,
                    line: Int = #line,
                    function: StaticString = #function) {
        writeLogEntry(items.map({ $0.description }), level: .verbose,
                      file: file, line: line, function: function)
    }

    func logWarning(_ items: CustomStringConvertible...,
                    file: StaticString = #file,
                    line: Int = #line,
                    function: StaticString = #function) {
        writeLogEntry(items.map({ $0.description }), level: .warning,
                      file: file, line: line, function: function)
    }

    func logError(_ items: CustomStringConvertible...,
                  file: StaticString = #file,
                  line: Int = #line,
                  function: StaticString = #function) {
        writeLogEntry(items.map({ $0.description }), level: .error,
                      file: file, line: line, function: function)
    }
}

class ConsoleLogger: LoggerType {

    var logLevel: LogLevel = .error
    var customName: String?
    var detailedOutput: Bool = false

    func writeLogEntry(_ items: [String],
                       level: LogLevel,
                       file: StaticString,
                       line: Int,
                       function: StaticString) {
        guard level >= logLevel, logLevel != .none else { return }

        let filename = file.description.components(separatedBy: "/").last ?? "N/A"
        let message = items.joined(separator: " ")

        if detailedOutput {
            print("[NStackSDK\(customName ?? "")] \(level.message) \(filename):\(line) – \(function) – \(message)")
        } else {
            print("[NStackSDK\(customName ?? "")] \(level.message) \(message)")
        }
    }
}
