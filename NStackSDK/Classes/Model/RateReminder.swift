//
//  RateReminder.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

public struct RateReminder: Codable {
    public var title: String
    public var body: String
    public var yesButtonTitle: String
    public var laterButtonTitle: String
    public var noButtonTitle: String
    public var link: URL?

    public enum CodingKeys: String, CodingKey {
        case title, body, link
        case yesButtonTitle = "yesBtn"
        case laterButtonTitle = "laterBtn"
        case noButtonTitle = "noBtn"
    }
}
