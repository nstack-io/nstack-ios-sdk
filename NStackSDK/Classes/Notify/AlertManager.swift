//
//  NotificationManager.swift
//  NStack
//
//  Created by Kasper Welner on 19/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import UIKit

public struct AlertManager {
        
    public enum RateReminderResult: String {
        case Rate = "yes"
        case Later = "later"
        case Never = "no"
    }
    
    public enum AlertType {
        case UpdateAlert(title:String, text:String, dismissButtonText:String?, appStoreButtonText:String, completion:(didPressAppStore:Bool) -> Void)
        case WhatsNewAlert(title: String, text: String, dismissButtonText: String, completion:() -> Void)
        case Message(text: String, dismissButtonText: String, completion:() -> Void)
        case RateReminder(title:String, text: String, rateButtonText:String, laterButtonText:String, neverButtonText:String, completion:(result:RateReminderResult) -> Void)
    }
    
    public static var sharedInstance = AlertManager()
    
    init() {
        self.alertWindow.windowLevel = UIWindowLevelAlert + 1
        self.alertWindow.rootViewController = UIViewController()
    }
    
    var alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
    
    var alreadyShowingAlert:Bool { return (AlertManager.sharedInstance.alertWindow.hidden == false) }
    
    public var showAlertBlock:(alertType:AlertType) -> Void = { (alertType:AlertType) -> Void in
        
        if AlertManager.sharedInstance.alreadyShowingAlert { return }
            
        var header:String?
        var message:String?
        var actions = [UIAlertAction]()
        
        switch alertType {
        case let .UpdateAlert(title, text, dismissText, appStoreText, completion):
            header = title
            message = String(NSString(format: text))
            if let dismissText = dismissText {
                actions.append(UIAlertAction(title: dismissText, style: UIAlertActionStyle.Default, handler: { action in
                    AlertManager.hideAlertWindow()
                    completion(didPressAppStore: false)
                }))
            }
            
            actions.append(UIAlertAction(title: appStoreText, style: UIAlertActionStyle.Default, handler: { action in
                AlertManager.hideAlertWindow()
                completion(didPressAppStore: true)
            }))
            
        case let .WhatsNewAlert(title, text, dismissButtonText, completion):
            header = title
            message = text
            actions.append(UIAlertAction(title: dismissButtonText, style: UIAlertActionStyle.Cancel, handler: { action in
                AlertManager.hideAlertWindow()
                completion()
            }))
            
        case let .Message(text, dismissButtonText, completion):
            message = text
            actions.append(UIAlertAction(title: dismissButtonText, style: UIAlertActionStyle.Cancel, handler: { action in
                AlertManager.hideAlertWindow()
                completion()
            }))
            
        case let .RateReminder(title, text, rateButtonText, laterButtonText, neverButtonText, completion):
            header = title
            message = text
            actions.append(UIAlertAction(title: rateButtonText, style: UIAlertActionStyle.Default, handler: { action in
                AlertManager.hideAlertWindow()
                completion(result: .Rate)
            }))
            actions.append(UIAlertAction(title: laterButtonText, style: UIAlertActionStyle.Default, handler: { action in
                AlertManager.hideAlertWindow()
                completion(result: .Later)
                
            }))
            actions.append(UIAlertAction(title: neverButtonText, style: UIAlertActionStyle.Cancel, handler: { action in
                AlertManager.hideAlertWindow()
                completion(result: .Never)
            }))
        }
        
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        for action in actions {
            alert.addAction(action)
        }
        
        AlertManager.sharedInstance.alertWindow.makeKeyAndVisible()
        AlertManager.sharedInstance.alertWindow.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    private static func hideAlertWindow() {
        AlertManager.sharedInstance.alertWindow.hidden = true
    }
    
    internal mutating func showUpdateAlert(newVersion version:Update.Version) {
        
        let appStoreCompletion =  { (didPressAppStore:Bool) -> Void in
            ConnectionManager.markNewerVersionAsSeen(version.lastId, appStoreButtonPressed: didPressAppStore)
            if didPressAppStore {
                if let link = version.link {
                    UIApplication.safeSharedApplication()?.safeOpenURL(link)
                }
            }
        }
                
        switch version.state {
        case .Force:
            let alertType = AlertManager.AlertType.UpdateAlert(title: version.translations.title, text: version.translations.message, dismissButtonText: nil, appStoreButtonText: version.translations.positiveBtn, completion:appStoreCompletion)
            self.showAlertBlock(alertType: alertType)
            
        case .Remind:
            let alertType = AlertManager.AlertType.UpdateAlert(title: version.translations.title, text: version.translations.message, dismissButtonText: version.translations.negativeBtn, appStoreButtonText: version.translations.positiveBtn, completion:appStoreCompletion)
            self.showAlertBlock(alertType: alertType)
            
        case .Disabled:
            return
        }
    }
    
    internal func showWhatsNewAlert(changeLog:Update.Changelog) {
        guard let translations = changeLog.translate else { return }
        let alertType = AlertManager.AlertType.WhatsNewAlert(title: translations.title, text: translations.message, dismissButtonText: "Ok") { () -> Void in
            ConnectionManager.markWhatsNewAsSeen(changeLog.lastId)
        }
        self.showAlertBlock(alertType: alertType)
    }
    
    internal func showMessage(message:Message) {
        let alertType = AlertManager.AlertType.Message(text: message.message, dismissButtonText: "Ok") { () -> Void in
            ConnectionManager.markMessageAsRead(message.id)
        }
        self.showAlertBlock(alertType: alertType)
    }
    
    internal func showRateReminder(rateReminder:RateReminder) {
        let alertType = AlertManager.AlertType.RateReminder(title: rateReminder.title, text: rateReminder.body, rateButtonText: rateReminder.rateBtn, laterButtonText: rateReminder.laterBtn, neverButtonText: rateReminder.neverBtn) { (result) -> Void in
            ConnectionManager.markRateReminderAsSeen(result)
            if let link = rateReminder.link where result == .Rate {
                UIApplication.safeSharedApplication()?.safeOpenURL(link)
            }
        }
        self.showAlertBlock(alertType: alertType)
    }
}