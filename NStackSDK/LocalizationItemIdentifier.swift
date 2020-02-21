//
//  TranslationIdentifier.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 01/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

public class LocalizationItemIdentifier: NSObject {
    let section: String
    let key: String

    init(section: String, key: String) {
        self.section = section
        self.key = key
    }
}
