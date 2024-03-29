//
//  RateReminderLogEventResponse.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 13/01/2022.
//  Copyright © 2022 Nodes ApS. All rights reserved.
//

import Foundation

public struct RateReminderLogEventResponse: Codable {
    public var guid: String
    public var points: Int
    
    public init(guid: String, points: Int) {
        self.guid = guid
        self.points = points
    }
}
