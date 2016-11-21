//
//  Timezone.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Serpent

public struct Timezone {
	public var id = 0
	public var name = ""
	public var abbreviation = "" //<-abbr
	public var offsetSec = 0
	public var label = ""
}

extension Timezone: Serializable {
	public init(dictionary: NSDictionary?) {
		id           <== (self, dictionary, "id")
		name         <== (self, dictionary, "name")
		abbreviation <== (self, dictionary, "abbr")
		offsetSec    <== (self, dictionary, "offset_sec")
		label        <== (self, dictionary, "label")
	}
	
	public func encodableRepresentation() -> NSCoding {
		let dict = NSMutableDictionary()
		(dict, "id")         <== id
		(dict, "name")       <== name
		(dict, "abbr")       <== abbreviation
		(dict, "offset_sec") <== offsetSec
		(dict, "label")      <== label
		return dict
	}
}
