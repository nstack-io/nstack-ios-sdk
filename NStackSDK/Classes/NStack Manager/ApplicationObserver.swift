//
//  ApplicationObserver.swift
//  NStack
//
//  Created by Kasper Welner on 25/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import Foundation
import Serializable
import Cashier

class ApplicationObserver {
    
    var first = true
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActive),
                                                         name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        if first {
            first = false
        } else {
            let prevAcceptLangString = NStack.persistentStore.objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String
            
            NStack.sharedInstance.update({ (error) -> Void in
                if let prevAcceptLangString = prevAcceptLangString where prevAcceptLangString != TranslationManager.sharedInstance.acceptLanguageHeaderValueString() {
                    NStack.sharedInstance.languageChangedHandler?()
                }
            })
        }
    }
}
