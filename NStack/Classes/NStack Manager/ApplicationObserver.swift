//
//  ApplicationObserver.swift
//  NStack
//
//  Created by Kasper Welner on 25/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import Serializable
import Cashier

class ApplicationObserver {
    
    var first = true
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        if first {
            first = false
        } else {
            
            let prevAcceptLangString:String? = NOPersistentStore.cacheWithId(NStackConstants.persistentStoreID).objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String
            
            NStack.sharedInstance.update({ (error) -> Void in
                if let prevAcceptLangString = prevAcceptLangString where prevAcceptLangString != TranslationManager.sharedInstance.acceptLanguageHeaderValueString() {
                    NStack.sharedInstance.languageChangedHandler?()
                }
            })
        }
    }
}
