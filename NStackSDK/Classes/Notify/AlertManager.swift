//
//  NotificationManager.swift
//  NStack
//
//  Created by Kasper Welner on 19/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
#if os(tvOS) || os(iOS)
import UIKit
import StoreKit
#endif

public class AlertManager {
    
    public enum RateReminderResult_v1: String {
        case rate = "yes"
        case later = "later"
        case never = "no"
    }
    
    public enum AlertType {
        case updateAlert(title: String,
                         text: String,
                         dismissButtonText: String?,
                         appStoreButtonText: String,
                         completion:(_ didPressAppStore: Bool) -> Void)
        case whatsNewAlert(title: String, text: String, dismissButtonText: String, completion: () -> Void)
        case message(text: String, url: URL?, dismissButtonText: String, openButtonText: String, completion: () -> Void)
        case rateReminder(title: String, body: String,
                          positiveButtonText: String,
                          negativeButtonText: String,
                          skipButtonText: String,
                          completion: (RateReminderResponse) -> Void)
    }
    
#if os(tvOS) || os(iOS)
    let repository: VersionsRepository
    
    var alertWindow = UIWindow(frame: UIScreen.main.bounds)
    
    public var alreadyShowingAlert: Bool {
        return !alertWindow.isHidden
    }
    
    // FIXME: Refactor
    public var showAlertBlock: (_ alertType: AlertType) -> Void = { alertType in
        DispatchQueue.main.async {
            guard !NStack.sharedInstance.alertManager.alreadyShowingAlert else {
                return
            }
            
            var header: String?
            var message: String?
            var actions = [UIAlertAction]()
            
            switch alertType {
            case let .updateAlert(title, text, dismissText, appStoreText, completion):
                header = title
                message = String(NSString(format: text as NSString))
                if let dismissText = dismissText {
                    actions.append(UIAlertAction(title: dismissText, style: .default, handler: { _ in
                        NStack.sharedInstance.alertManager.hideAlertWindow()
                        completion(false)
                    }))
                }
                
                actions.append(UIAlertAction(title: appStoreText, style: .default, handler: { _ in
                    NStack.sharedInstance.alertManager.hideAlertWindow()
                    completion(true)
                }))
                
            case let .whatsNewAlert(title, text, dismissButtonText, completion):
                header = title
                message = text
                actions.append(UIAlertAction(title: dismissButtonText, style: .cancel, handler: { _ in
                    NStack.sharedInstance.alertManager.hideAlertWindow()
                    completion()
                }))
                
            case let .message(text, url, dismissButtonText, openButtonText, completion):
                message = text
                
                // Add Open URL button to alert if url's present
                if let url = url, !openButtonText.isEmpty {
                    actions.append(UIAlertAction(title: openButtonText, style: .default, handler: { _ in
                        UIApplication.safeSharedApplication()?.safeOpenURL(url)
                        
                        NStack.sharedInstance.alertManager.hideAlertWindow()
                        
                        completion()
                    }))
                }
                
                actions.append(UIAlertAction(title: dismissButtonText, style: .cancel, handler: { _ in
                    NStack.sharedInstance.alertManager.hideAlertWindow()
                    
                    completion()
                }))
            case .rateReminder(let title, let body, let positiveButtonText, let negativeButtonText, let skipButtonText, let completion):
                header = title
                message = body
                actions.append(UIAlertAction(title: positiveButtonText, style: .default, handler: { _ in
                    NStack.sharedInstance.alertManager.hideAlertWindow()
                    completion(.positive)
                }))
                actions.append(UIAlertAction(title: negativeButtonText, style: .default, handler: { _ in
                    NStack.sharedInstance.alertManager.hideAlertWindow()
                    completion(.negative)
                }))
                actions.append(UIAlertAction(title: skipButtonText, style: .cancel, handler: { _ in
                    NStack.sharedInstance.alertManager.hideAlertWindow()
                    completion(.skip)
                }))
            }
            
            let alert = UIAlertController(title: header, message: message, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            
            NStack.sharedInstance.alertManager.alertWindow.makeKeyAndVisible()
            NStack.sharedInstance.alertManager.alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    public var requestAppStoreReview: () -> Void = {
        if #available(iOSApplicationExtension 10.3, *) {
#if os(iOS)
            SKStoreReviewController.requestReview()
#endif
        }
    }
    
    // MARK: - Lifecyle -
    
    init(repository: VersionsRepository) {
        self.repository = repository
        self.alertWindow.windowLevel = UIWindow.Level.alert + 1
        self.alertWindow.rootViewController = UIViewController()
    }
    
    public func hideAlertWindow() {
        DispatchQueue.main.async {
            self.alertWindow.isHidden = true
        }
    }
    
    internal func showUpdateAlert(newVersion version: Update.Version) {
        
        let appStoreCompletion = { (didPressAppStore: Bool) -> Void in
            if didPressAppStore {
                if let link = version.link {
                    UIApplication.safeSharedApplication()?.safeOpenURL(link)
                }
            }
        }
        
        let alertType: AlertType
        
        switch version.state {
        case .force:
            alertType = AlertType.updateAlert(title: version.localizations.title,
                                              text: version.localizations.message,
                                              dismissButtonText: nil,
                                              appStoreButtonText: version.localizations.positiveBtn ?? "",
                                              completion: appStoreCompletion)
        case .remind:
            alertType = AlertType.updateAlert(title: version.localizations.title,
                                              text: version.localizations.message,
                                              dismissButtonText: version.localizations.negativeBtn,
                                              appStoreButtonText: version.localizations.positiveBtn ?? "",
                                              completion: appStoreCompletion)
        case .disabled:
            return
        }
        
        self.showAlertBlock(alertType)
    }
    
    internal func showWhatsNewAlert(_ changeLog: Update.Changelog) {
        guard let localizations = changeLog.localizations else { return }
        let alertType = AlertType.whatsNewAlert(title: localizations.title,
                                                text: localizations.message,
                                                dismissButtonText: "Ok") {
            self.repository.markWhatsNewAsSeen(changeLog.lastId)
        }
        
        showAlertBlock(alertType)
    }
    
    internal func showMessage(_ message: Message) {
        let alertType = AlertType.message(
            text: message.message,
            url: message.url,
            dismissButtonText: message.localization?["okBtn"] ?? "Ok",
            openButtonText: message.localization?["urlBtn"] ?? "Open URL") {
                self.repository.markMessageAsRead(message.id)
            }
        
        showAlertBlock(alertType)
    }
    
    internal func showRateReminderV1(_ rateReminder: RateReminder) {
        self.requestAppStoreReview()
        if let result = AlertManager.RateReminderResult_v1(rawValue: "yes") {
            self.repository.markRateReminderAsSeen(result)
        }
    }
    
    internal func showRateReminderCheck(_ model: RateReminderAlertModel,
                                        completion: @escaping ((RateReminderResponse) -> Void)) {
        let localizations = model.localization
        let alertType = AlertType.rateReminder(title: localizations.title,
                                               body: localizations.body,
                                               positiveButtonText: localizations.yesBtn,
                                               negativeButtonText: localizations.noBtn,
                                               skipButtonText: localizations.laterBtn,
                                               completion: completion)
        showAlertBlock(alertType)
    }
#endif
}
