//
//  Feedback.swift
//  NStackSDK
//
//  Created by Tiago Bras on 31/10/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum FeedbackType: String {
    case feedback, bug
}

struct Breadcrumbs {
    var event: String
    var timestamp: Date
}

struct Feedback {
    var type: FeedbackType
    var appVersion: String?
    var name: String?
    var email: String?
    var message: String?
    #if canImport(UIKit)
    var image: UIImage?
    #endif
    var breadcrumbs: Breadcrumbs?
}
