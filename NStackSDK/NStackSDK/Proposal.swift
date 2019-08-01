//
//  Proposal.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 30/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

public struct Proposal: Codable {
    let id, applicationId: Int
    let key, section, locale, value: String //make extension which exposes an actual Locale
}
