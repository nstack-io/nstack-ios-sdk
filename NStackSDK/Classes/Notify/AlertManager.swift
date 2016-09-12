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
        case updateAlert(title:String, text:String, dismissButtonText:String?, appStoreButtonText:String, completion:(_ didPressAppStore:Bool) -> Void)
        case whatsNewAlert(title: String, text: String, dismissButtonText: String, completion:() -> Void)
        case message(text: String, dismissButtonText: String, completion:() -> Void)
        case rateReminder(title:String, text: String, rateButtonText:String, laterButtonText:String, neverButtonText:String, completion:(_ result:RateReminderResult) -> Void)
    }
    
    public static var sharedInstance = AlertManager()
    
    
    
    init() {
        self.alertWindow.windowLevel = UIWindowLevelAlert + 1
        self.alertWindow.rootViewController = UIViewController()
    }
    
    var alertWindow = UIWindow(frame: UIScreen.main.bounds)
    
    var alreadyShowingAlert:Bool { return (AlertManager.sharedInstance.alertWindow.isHidden == false) }
    
    public var showAlertBlock:(_ alertType:AlertType) -> Void = { (alertType:AlertType) -> Void in
        
        if AlertManager.sharedInstance.alreadyShowingAlert { return }
            
        var header:String?
        var message:String?
        var actions = [UIAlertAction]()
        
        switch alertType {
        case let .updateAlert(title, text, dismissText, appStoreText, completion):
            header = title
            message = String(NSString(format: text as NSString))
            if let dismissText = dismissText {
                actions.append(UIAlertAction(title: dismissText, style: UIAlertActionStyle.default, handler: { action in
                    AlertManager.hideAlertWindow()
                    completion(false)
                }))
            }
            
            actions.append(UIAlertAction(title: appStoreText, style: UIAlertActionStyle.default, handler: { action in
                AlertManager.hideAlertWindow()
                completion(true)
            }))
            
        case let .whatsNewAlert(title, text, dismissButtonText, completion):
            header = title
            message = text
            actions.append(UIAlertAction(title: dismissButtonText, style: UIAlertActionStyle.cancel, handler: { action in
                AlertManager.hideAlertWindow()
                completion()
            }))
            
        case let .message(text, dismissButtonText, completion):
            message = text
            actions.append(UIAlertAction(title: dismissButtonText, style: UIAlertActionStyle.cancel, handler: { action in
                AlertManager.hideAlertWindow()
                completion()
            }))
            
        case let .rateReminder(title, text, rateButtonText, laterButtonText, neverButtonText, completion):
            header = title
            message = text
            actions.append(UIAlertAction(title: rateButtonText, style: UIAlertActionStyle.default, handler: { action in
                AlertManager.hideAlertWindow()
                completion(.Rate)
            }))
            actions.append(UIAlertAction(title: laterButtonText, style: UIAlertActionStyle.default, handler: { action in
                AlertManager.hideAlertWindow()
                completion(.Later)
                
            }))
            actions.append(UIAlertAction(title: neverButtonText, style: UIAlertActionStyle.cancel, handler: { action in
                AlertManager.hideAlertWindow()
                completion(.Never)
            }))
        }
        
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for action in actions {
            alert.addAction(action)
        }
        
        AlertManager.sharedInstance.alertWindow.makeKeyAndVisible()
        AlertManager.sharedInstance.alertWindow.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    fileprivate static func hideAlertWindow() {
        AlertManager.sharedInstance.alertWindow.isHidden = true
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
            let alertType = AlertManager.AlertType.updateAlert(title: version.translations.title, text: version.translations.message, dismissButtonText: nil, appStoreButtonText: version.translations.positiveBtn, completion:appStoreCompletion)
            self.showAlertBlock(alertType)
            
        case .Remind:
            let alertType = AlertManager.AlertType.updateAlert(title: version.translations.title, text: version.translations.message, dismissButtonText: version.translations.negativeBtn, appStoreButtonText: version.translations.positiveBtn, completion:appStoreCompletion)
            self.showAlertBlock(alertType)
            
        case .Disabled:
            return
        }
    }
    
    internal func showWhatsNewAlert(_ changeLog:Update.Changelog) {
        guard let translations = changeLog.translate else { return }
        let alertType = AlertManager.AlertType.whatsNewAlert(title: translations.title, text: translations.message, dismissButtonText: "Ok") { () -> Void in
            NStackConnectionManager.markWhatsNewAsSeen(changeLog.lastId)
        }
        self.showAlertBlock(alertType)
    }

    internal func showMessage(_ message:Message) {
        let alertType = AlertManager.AlertType.message(text: message.message, dismissButtonText: "Ok") { () -> Void in
            NStackConnectionManager.markMessageAsRead(message.id)
        }
        self.showAlertBlock(alertType)
    }

    internal func showRateReminder(_ rateReminder:RateReminder) {
        let alertType = AlertManager.AlertType.rateReminder(title: rateReminder.title, text: rateReminder.body, rateButtonText: rateReminder.rateBtn, laterButtonText: rateReminder.laterBtn, neverButtonText: rateReminder.neverBtn) { (result) -> Void in
            NStackConnectionManager.markRateReminderAsSeen(result)
            
            if result == .Rate, let link = rateReminder.link {
                UIApplication.safeSharedApplication()?.safeOpenURL(link)
            }
        }
        self.showAlertBlock(alertType)
    }
}
