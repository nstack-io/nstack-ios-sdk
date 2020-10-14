//
//  Feedback.swift
//  NStackSDK
//
//  Created by Tiago Bras on 31/10/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//
#if canImport(UIKit)
import UIKit
public typealias Image = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias Image = NSImage
#elseif canImport(WatchKit)
import WatchKit
public typealias Image = WKImage
#endif

public enum FeedbackType: String {
    case feedback, bug
}

struct Breadcrumbs {
    var event: String
    var timestamp: Date
}

public struct Feedback {
    var type: FeedbackType
    var appVersion: String?
    var name: String?
    var email: String?
    var message: String?
    var image: Image?
    var breadcrumbs: Breadcrumbs?
}
