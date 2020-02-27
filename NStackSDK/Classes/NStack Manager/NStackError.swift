//
//  NStackError.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 14/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public enum NStackError {
    public enum Manager: Error {
        case notConfigured
        case updateFailed(reason: String)
        case parsing(reason: String)

        var description: String {
            switch self {
            case .notConfigured: return "NStack needs to be configured before it can be used. Please, call the `start` function first."
            case .updateFailed(let reason): return reason
            case .parsing(let reason): return reason
            }
        }
    }

    public enum Localization: Error {
        case updateFailed(reason: String)

        var description: String {
            switch self {
            case .updateFailed(let reason): return reason
            }
        }
    }

    public enum GeographyManager: Error {
        case noResourceAvailable

        var description: String {
            switch self {
            case .noResourceAvailable: return "No resource JSON available"
            }
        }
    }
}
