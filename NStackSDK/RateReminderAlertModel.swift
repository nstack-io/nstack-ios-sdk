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
    
    public init(id: Int, localization: RateReminderAlertModelLocalization) {
        self.id = id
        self.localization = localization
    }
}

public struct RateReminderAlertModelLocalization: Codable {
    public var title: String
    public var body: String
    public var yesBtn: String
    public var laterBtn: String
    public var noBtn: String
    
    public init(
        title: String,
        body: String,
        yesBtn: String,
        laterBtn: String,
        noBtn: String
    ) {
        self.title = title
        self.body = body
        self.yesBtn = yesBtn
        self.laterBtn = laterBtn
        self.noBtn = noBtn
    }
}
