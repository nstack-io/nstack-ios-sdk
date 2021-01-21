//
//  StoreReviewManager.swift
//  NStackSDK
//
//  Created by Mauran Muthiah on 30/08/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Foundation
import StoreKit

class StoreReviewManager {
    static func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
