//
//  AppOpenResponse.swift
//  NStack
//
//  Created by Andrew Lloyd on 04/02/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

// TODO: Fix update struct in app open and adjust fetchUpdates response model

struct AppOpenResponse: Codable {
    let data: AppOpenData?
    let languageData: LanguageData?

    enum CodingKeys: String, CodingKey {
        case data, languageData = "meta"
    }
}
