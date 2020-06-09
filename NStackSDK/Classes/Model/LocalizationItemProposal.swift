//
//  LocalizationProposal.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
#endif


struct LocalizationItemProposal {
    let value: String
    let locale: Locale
}
