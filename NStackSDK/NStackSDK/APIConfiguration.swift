//
//  APIConfiguration.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 02/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

struct APIConfiguration {
    let appId: String
    let restAPIKey: String
    let isFlat: Bool
    let localizationUrlOverride: String?
    let nmeta: NMeta

    init(appId: String = "",
         restAPIKey: String = "",
         isFlat: Bool = false,
         localizationUrlOverride: String? = nil,
         nmeta: NMeta) {
        self.appId = appId
        self.restAPIKey = restAPIKey
        self.isFlat = isFlat
        self.localizationUrlOverride = localizationUrlOverride
        self.nmeta = nmeta
    }
}
