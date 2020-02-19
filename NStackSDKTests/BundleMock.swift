//
//  BundleMock.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 09/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

class BundleMock: Bundle {
    var resourcePathOverride: String?
    var resourceNameOverride: String?

    override func path(forResource name: String?, ofType ext: String?) -> String? {
        return resourcePathOverride ?? super.path(forResource: resourceNameOverride ?? name, ofType: ext)
    }
}
