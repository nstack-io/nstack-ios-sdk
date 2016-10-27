//
//  Country.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Serializable

public struct Country {
	var id = 0
	var name = ""
	var code = ""
	var codeIso = ""
	var native = ""
	var phone = 0
	var continent = ""
	var capital = ""
	var capitalLat = 0.0
	var capitalLng = 0.0
	var currency = ""
	var currencyName = ""
	var languages = ""
	var image: UIImage?
	var image2: UIImage? //<-image_2
	var timezone = Timezone()
}

extension Country: Serializable {
	public init(dictionary: NSDictionary?) {
		id           <== (self, dictionary, "id")
		name         <== (self, dictionary, "name")
		code         <== (self, dictionary, "code")
		codeIso      <== (self, dictionary, "code_iso")
		native       <== (self, dictionary, "native")
		phone        <== (self, dictionary, "phone")
		continent    <== (self, dictionary, "continent")
		capital      <== (self, dictionary, "capital")
		capitalLat   <== (self, dictionary, "capital_lat")
		capitalLng   <== (self, dictionary, "capital_lng")
		currency     <== (self, dictionary, "currency")
		currencyName <== (self, dictionary, "currency_name")
		languages    <== (self, dictionary, "languages")
		image        <== (self, dictionary, "image")
		image2       <== (self, dictionary, "image_2")
		timezone     <== (self, dictionary, "timezone")
	}
	
	public func encodableRepresentation() -> NSCoding {
		let dict = NSMutableDictionary()
		(dict, "id")            <== id
		(dict, "name")          <== name
		(dict, "code")          <== code
		(dict, "code_iso")      <== codeIso
		(dict, "native")        <== native
		(dict, "phone")         <== phone
		(dict, "continent")     <== continent
		(dict, "capital")       <== capital
		(dict, "capital_lat")   <== capitalLat
		(dict, "capital_lng")   <== capitalLng
		(dict, "currency")      <== currency
		(dict, "currency_name") <== currencyName
		(dict, "languages")     <== languages
		(dict, "image")         <== image
		(dict, "image_2")       <== image2
		(dict, "timezone")      <== timezone
		return dict
	}
}
