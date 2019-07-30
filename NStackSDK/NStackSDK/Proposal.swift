//
//  Proposal.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 30/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

public struct Proposal: Codable {
    let id: Int
    let applicationId: Int
    let section: String
    let key: String
    let value: String
    let locale: String //make extension which exposes an actual Locale
}
