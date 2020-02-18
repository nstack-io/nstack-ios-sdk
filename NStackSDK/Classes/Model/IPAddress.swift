//
//  IPAddress.swift
//  NStackSDK
//
//  Created by Christian Graver on 01/11/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Foundation

public struct IPAddress: Codable {
    public let ipStart: String
    public let ipEnd: String
    public let country: String
    public let stateProv: String
    public let city: String
    public let lat: Double
    public let lng: Double
    public let timeZoneOffset: String
    public let timeZoneName: String
    public let ispName: String
    public let connectionType: String
    public let type: String
    public let requiredIp: String
}
