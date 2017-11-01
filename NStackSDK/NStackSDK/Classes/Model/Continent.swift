//
//  Continent.swift
//  NStackSDK
//
//  Created by Christian Graver on 01/11/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Serpent

public struct Continent {
    public var id = 0
    public var name = ""
    public var code = ""
    public var imageURL: URL? //<- image
}

extension Continent: Serializable {
    public init(dictionary: NSDictionary?) {
        id       <== (self, dictionary, "id")
        name     <== (self, dictionary, "name")
        code     <== (self, dictionary, "code")
        imageURL <== (self, dictionary, "image")
    }
    
    public func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")    <== id
        (dict, "name")  <== name
        (dict, "code")  <== code
        (dict, "image") <== imageURL
        return dict
    }
}

