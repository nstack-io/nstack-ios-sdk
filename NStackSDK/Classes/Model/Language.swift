//
//  Language.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable

public struct Language {
    public var id = 0
    public var name = ""
    public var locale = ""
    public var direction = ""
    public var data:NSDictionary = [:]
}

extension Language: Serializable {
    public init(dictionary: NSDictionary?) {
        id        <== (self, dictionary, "id")
        name      <== (self, dictionary, "name")
        locale    <== (self, dictionary, "locale")
        direction <== (self, dictionary, "direction")
        data      <== (self, dictionary, "data")
    }
    
    public func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")        <== id
        (dict, "name")      <== name
        (dict, "locale")    <== locale
        (dict, "direction") <== direction
        (dict, "data")      <== data
        return dict
    }
}