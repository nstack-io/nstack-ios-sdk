//
//  LocalizationProposal.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import LocalizationManager
#elseif os(tvOS)
import LocalizationManager_tvOS
#elseif os(watchOS)
import LocalizationManager_watchOS
#elseif os(macOS)

#endif

struct LocalizationProposal {
    let value: String
    let locale: Locale
}
