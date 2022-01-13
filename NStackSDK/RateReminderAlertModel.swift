//
//  RateReminderAlertModel.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 13/01/2022.
//  Copyright © 2022 Nodes ApS. All rights reserved.
//

import Foundation

public struct RateReminderAlertModel: Codable {
    public var id: Int
    public var localization: RateReminderAlertModelLocalization
}

public struct RateReminderAlertModelLocalization: Codable {
    public var title: String
    public var body: String
    public var yesBtn: String
    public var laterBtn: String
    public var noBtn: String
}
