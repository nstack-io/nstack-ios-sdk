//
//  LocalizableModel.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

open class LocalizableModel: Codable {
    public init() {}
    open subscript(key: String) -> LocalizableSection? {
        return nil
    }
}

open class LocalizableSection: Codable {
    public init() {}
    open subscript(key: String) -> String? {
        return nil
    }
}
