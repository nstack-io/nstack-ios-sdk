//
//  LocalizationMeta.swift
//  LocalizationManager
//
//  Created by Andrew Lloyd on 24/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

public struct LocalizationMeta<L: LanguageModel>: Codable {
    public let language: L?
    public let platform: Platform?

    public init( language: L? = nil,
                 platform: Platform? = nil ) {
        self.language = language
        self.platform = platform
    }
}
