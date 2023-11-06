//
//  Update.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

public enum UpdateState: String, Codable {
    case disabled    = "no"
    case remind      = "yes"
    case force       = "force"
}

public struct Update: Codable {
    public let newInThisVersion: Changelog?
    public let newerVersion: Version?

    public enum CodingKeys: String, CodingKey {
        case newInThisVersion = "new_in_version"
        case newerVersion = "newer_version"
    }

    public struct UpdateLocalizations: Codable {
        public let title: String
        public let message: String
        public let positiveBtn: String?
        public let negativeBtn: String?
    }

    public struct Changelog: Codable {
        public let state: Bool
        public let lastId: Int
        public let version: String
        public let localizations: UpdateLocalizations?

        public enum CodingKeys: String, CodingKey {
            case state, version, localizations
            case lastId = "last_id"
        }
    }

    public struct Version: Codable {
        public let state: UpdateState
        public let lastId: Int
        public let version: String
        public let localizations: UpdateLocalizations
        public let link: URL?

        public enum CodingKeys: String, CodingKey {
            case state, version, link
            case lastId = "last_id"
            case localizations = "translate"
        }
    }
}
