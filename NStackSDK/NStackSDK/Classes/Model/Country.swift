//
//  Country.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Serpent

public struct Country {
	public var id = 0
	public var name = ""
	public var code = ""
	public var codeIso = ""
	public var native = ""
	public var phone = 0
	public var continent = ""
	public var capital = ""
	public var capitalLat = 0.0
	public var capitalLng = 0.0
	public var currency = ""
	public var currencyName = ""
	public var languages = ""
	public var image: URL?
	public var imagePath2: URL? //<- image_path_2
	public var capitalTimeZone = Timezone()
}

extension Country: Serializable {
    public init(dictionary: NSDictionary?) {
        id              <== (self, dictionary, "id")
        name            <== (self, dictionary, "name")
        code            <== (self, dictionary, "code")
        codeIso         <== (self, dictionary, "code_iso")
        native          <== (self, dictionary, "native")
        phone           <== (self, dictionary, "phone")
        continent       <== (self, dictionary, "continent")
        capital         <== (self, dictionary, "capital")
        capitalLat      <== (self, dictionary, "capital_lat")
        capitalLng      <== (self, dictionary, "capital_lng")
        currency        <== (self, dictionary, "currency")
        currencyName    <== (self, dictionary, "currency_name")
        languages       <== (self, dictionary, "languages")
        image           <== (self, dictionary, "image")
        imagePath2      <== (self, dictionary, "image_path_2")
        capitalTimeZone <== (self, dictionary, "capital_time_zone")
    }

    public func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")                <== id
        (dict, "name")              <== name
        (dict, "code")              <== code
        (dict, "code_iso")          <== codeIso
        (dict, "native")            <== native
        (dict, "phone")             <== phone
        (dict, "continent")         <== continent
        (dict, "capital")           <== capital
        (dict, "capital_lat")       <== capitalLat
        (dict, "capital_lng")       <== capitalLng
        (dict, "currency")          <== currency
        (dict, "currency_name")     <== currencyName
        (dict, "languages")         <== languages
        (dict, "image")             <== image
        (dict, "image_path_2")      <== imagePath2
        (dict, "capital_time_zone") <== capitalTimeZone
        return dict
    }
}
