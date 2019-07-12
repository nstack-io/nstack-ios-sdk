//
//  Continent.swift
//  NStackSDK
//
//  Created by Christian Graver on 01/11/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Foundation

public struct Continent: Codable {
    let id: Int
    let name: String
    let code: String
    let imageUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, code
        case imageUrl = "image"
    }
}
