//
//  Timezone.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public struct Timezone: Codable {
    public var id: Int
	public var name: String
	public var abbreviation: String
    public var offsetSec: Int
    public var label: String

    enum CodingKeys: String, CodingKey {
        case id, name, offsetSec, label
        case abbreviation = "abbr"
    }
}
