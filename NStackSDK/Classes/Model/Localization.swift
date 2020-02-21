//
//  Localization.swift
//  NStackSDK
//
//  Created by Andrew Lloyd on 27/06/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import LocalizationManager

//public struct Localization: LocalizationModel {
//
//    public var id: Int
//    public var url: String
//    public var lastUpdatedAt: String
//    public var shouldUpdate: Bool
//    public var language: Language
//
//    enum CodingKeys: String, CodingKey {
//        case language, url, id
//        case lastUpdatedAt = "last_updated_at"
//        case shouldUpdate = "should_update"
//    }
//
//    public var localeIdentifier: String {
//        return language.acceptLanguage
//    }
//}
