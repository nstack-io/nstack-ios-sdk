//
//  NStackError.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 14/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public enum NStackError {
    public enum Manager: ErrorType {
        case NotConfigured
        case UpdateFailed(reason: String)

        var description: String {
            switch self {
            case .NotConfigured: return "NStack needs to be configured before it can be used. Please, call the `start` function first."
            case .UpdateFailed(let reason): return reason
            }
        }
    }

    public enum Translations: ErrorType {
        case NotConfigured
        case UpdateFailed(reason: String)

        var description: String {
            switch self {
            case .NotConfigured: return "Translations Manager has to be configured first before it can be used. Please call `start(translationsType:)` before calling any other functions."
            case .UpdateFailed(let reason): return reason
            }
        }
    }
}