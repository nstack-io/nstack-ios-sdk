//
//  LocalizationProposal.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if os(iOS)
import TranslationManager
#elseif os(tvOS)
import TranslationManager_tvOS
#endif

struct LocalizationProposal {
    let value: String
    let locale: Locale
}
