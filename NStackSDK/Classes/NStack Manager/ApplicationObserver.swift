//
//  ApplicationObserver.swift
//  NStack
//
//  Created by Kasper Welner on 25/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import Foundation

class ApplicationObserver {
    
    var first = true
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                                         name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        if first {
            first = false
        } else {
            let prevAcceptLangString = NStack.persistentStore.object(forKey: NStackConstants.prevAcceptedLanguageKey) as? String
            NStack.sharedInstance.update({ (error) -> Void in
                if let prevAcceptLangString = prevAcceptLangString, prevAcceptLangString != TranslationManager.sharedInstance.acceptLanguageHeaderValueString() {
                    NStack.sharedInstance.languageChangedHandler?()
                }
            })
        }
    }
}
