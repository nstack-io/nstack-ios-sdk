//
//  Platform.swift
//  LocalizationManager
//
//  Created by Andrew Lloyd on 24/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public struct Platform: Codable {
    public let id: Int
    public let slug: String

    public init(id: Int, slug: String) {
        self.id = id
        self.slug = slug
    }
}
