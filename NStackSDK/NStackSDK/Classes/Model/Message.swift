//
//  Message.swift
//  NStack
//
//  Created by Kasper Welner on 21/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

internal struct Message: Codable {
    let id: Int
    let message: String
    let showSetting: String
    let url: URL?

    /// Temporary solution for localizing the message's buttons
    /// - Valid keys: `okBtn`, `urlBtn`
    let localization: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id, message
        case showSetting = "show_setting"
        case url
        case localization
    }
}
