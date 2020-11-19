//
//  String+Substring.swift
//  LocalizationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

extension String {

    func lowerCaseFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}
