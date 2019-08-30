//
//  SectionKeyHelper.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 01/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

struct SectionKeyHelper {

    static func split(_ sectionAndKey: String) -> (section: String, key: String)? {
        let seperated = sectionAndKey.split(separator: ".")
        if seperated.count == 2 {
            let sect = seperated[0] == "defaultSection" ? "default" : seperated[0]
            return ("\(sect)", "\(seperated[1])")
        }
        return nil
    }

    static func combine(section: String, key: String) -> String {
        return "\(section).\(key)"
    }

    static func transform(_ sectionAndKey: String) -> LocalizationItemIdentifier? {
        guard let tuple = split(sectionAndKey) else { return nil }
        return LocalizationItemIdentifier(section: tuple.section, key: tuple.key)
    }

}
