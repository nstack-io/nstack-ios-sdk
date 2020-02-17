//
//  RateReminder.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

struct RateReminder: Codable {
    var title: String
    var body: String
    var yesButtonTitle: String
    var laterButtonTitle: String
    var noButtonTitle: String
    var link: URL?

    enum CodingKeys: String, CodingKey {
        case title, body, link
        case yesButtonTitle = "yesBtn"
        case laterButtonTitle = "laterBtn"
        case noButtonTitle = "noBtn"
    }
}
