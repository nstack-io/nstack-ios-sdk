//
//  SectionKeyHelper.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 01/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

struct SectionKeyHelper {
    
    func split(_ sectionAndKey: String) -> (section: String, key: String)? {
        let seperated = sectionAndKey.split(separator: ".")
        if seperated.count == 2 {
            return ("\(seperated[0])","\(seperated[1])")
        }
        return nil
    }
    
    func combine(section: String, key: String) -> String {
        return "\(section).\(key)"
    }
    
}
