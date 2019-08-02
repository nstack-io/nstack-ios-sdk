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
    let key: String
    let section: String
    private let localeString: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case applicationId
        case key
        case section
        case localeString = "locale"
        case value
    }
}

extension Proposal {
    var locale: Locale? {
        return Locale(identifier: localeString)
    }
}
