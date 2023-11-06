//
//  Message.swift
//  NStack
//
//  Created by Kasper Welner on 21/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

public struct Message: Codable {
    public let id: Int
    public let message: String
    public let showSetting: String
    public let url: URL?

    /// Temporary solution for localizing the message's buttons
    /// - Valid keys: `okBtn`, `urlBtn`
    public let localization: [String: String]?

    public enum CodingKeys: String, CodingKey {
        case id, message
        case showSetting = "show_setting"
        case url
        case localization
    }
}
