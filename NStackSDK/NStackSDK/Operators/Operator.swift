//
//  Operator.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 29/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

infix operator <=>

/*
 OK so we wan't to return the value from the localization manager, unless a local proposal exists
 and we wan't to do so for the selected language
 
 So label.text <=> tr.myvalue.myvalue = give me the string for "tr.myvalue.myvalue" for the current language
*/

public func <=> (left: NStackLocalizable, right: String) {
    left.localize(for: right)
}

public func <=> (left: NStackLocalizable, right: LocalizationItemIdentifier) {
    NStack.sharedInstance.localizationManager?.localize(component: left, for: right)
}
