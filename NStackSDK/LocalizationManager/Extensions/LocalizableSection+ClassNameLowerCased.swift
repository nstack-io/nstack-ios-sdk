//
//  LocalizableSection+classNameLowerCased.swift
//  LocalizationManager
//
//  Created by Bob De Kort on 08/08/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation

extension LocalizableSection {
    open func classNameLowerCased() -> String {
        return String(describing: type(of: self)).lowerCaseFirstLetter()
    }
}
