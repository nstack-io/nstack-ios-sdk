//
//  UITextView+NStackLocalizable.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 30/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

extension UITextView: NStackLocalizable {

    private static var _backgroundColor = [String: UIColor?]()
    private static var _userInteractionEnabled = [String: Bool]()
    private static var _localizationItemIdentifier = [String: LocalizationItemIdentifier]()

    @objc public func localize(for stringIdentifier: String) {
        guard let identifier = SectionKeyHelper.transform(stringIdentifier) else { return }
        NStack.sharedInstance.localizationManager?.localize(component: self, for: identifier)
    }

    @objc public func setLocalizedValue(_ localizedValue: String) {
        text = localizedValue
    }

    public var localizableValue: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }

    public var localizationItemIdentifier: LocalizationItemIdentifier? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UITextView._localizationItemIdentifier[tmpAddress]
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UITextView._localizationItemIdentifier[tmpAddress] = newValue
        }
    }

    public var originalBackgroundColor: UIColor? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UITextView._backgroundColor[tmpAddress] ?? .clear
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UITextView._backgroundColor[tmpAddress] = newValue
        }
    }

    public var originalIsUserInteractionEnabled: Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UITextView._userInteractionEnabled[tmpAddress] ?? false
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UITextView._userInteractionEnabled[tmpAddress] = newValue
        }
    }

    public var backgroundViewToColor: UIView? {
        return self
    }

}
