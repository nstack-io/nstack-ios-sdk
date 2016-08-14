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
        case UpdateFailed(reason: String)
    }

    public enum Translations: ErrorType {
        case UpdateFailed(reason: String)
    }
}