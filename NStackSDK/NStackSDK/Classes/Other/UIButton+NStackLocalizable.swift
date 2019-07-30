//
//  UIButton+NStackLocalizable.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 30/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

extension UIButton: NStackLocalizable {
    
    private static var _backgroundColor = [String: UIColor?]()
    private static var _userInteractionEnabled = [String:Bool]()
    
    public func setLocalizedValue(_ localizedValue: String) {
        
    }
    
    public var translatableValue: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }
    
    public var originalBackgroundColor: UIColor? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIButton._backgroundColor[tmpAddress] ?? .clear
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIButton._backgroundColor[tmpAddress] = newValue
        }
    }
    
    public var originalIsUserInteractionEnabled: Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIButton._userInteractionEnabled[tmpAddress] ?? false
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIButton._userInteractionEnabled[tmpAddress] = newValue
        }
    }
    
    public var backgroundViewToColor: UIView? {
        return titleLabel
    }
    
}
