//
//  IPAddress.swift
//  NStackSDK
//
//  Created by Christian Graver on 01/11/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Serpent

public struct IPAddress {
    public var ipStart = ""
    public var ipEnd = ""
    public var country = ""
    public var stateProv = ""
    public var city = ""
    public var lat = ""
    public var lng = ""
    public var timeZoneOffset = ""
    public var timeZoneName = ""
    public var ispName = ""
    public var connectionType = ""
    public var type = ""
    public var requestedIp = ""
}

extension IPAddress: Serializable {
    public init(dictionary: NSDictionary?) {
        ipStart        <== (self, dictionary, "ip_start")
        ipEnd          <== (self, dictionary, "ip_end")
        country        <== (self, dictionary, "country")
        stateProv      <== (self, dictionary, "state_prov")
        city           <== (self, dictionary, "city")
        lat            <== (self, dictionary, "lat")
        lng            <== (self, dictionary, "lng")
        timeZoneOffset <== (self, dictionary, "time_zone_offset")
        timeZoneName   <== (self, dictionary, "time_zone_name")
        ispName        <== (self, dictionary, "isp_name")
        connectionType <== (self, dictionary, "connection_type")
        type           <== (self, dictionary, "type")
        requestedIp    <== (self, dictionary, "requested_ip")
    }
    
    public func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "ip_start")         <== ipStart
        (dict, "ip_end")           <== ipEnd
        (dict, "country")          <== country
        (dict, "state_prov")       <== stateProv
        (dict, "city")             <== city
        (dict, "lat")              <== lat
        (dict, "lng")              <== lng
        (dict, "time_zone_offset") <== timeZoneOffset
        (dict, "time_zone_name")   <== timeZoneName
        (dict, "isp_name")         <== ispName
        (dict, "connection_type")  <== connectionType
        (dict, "type")             <== type
        (dict, "requested_ip")     <== requestedIp
        return dict
    }
}

