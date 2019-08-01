//
//  UIWindow+ShakeDetection.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 29/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    private struct ShakeDetection {
        static var isEditing = false
        static var translatableSubviews: [NStackLocalizable] = []
    }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            if ShakeDetection.isEditing {
                revertAndReset()
                return
            }
            
            if let topController = visibleViewController() {
                
                // TODO: Observe for viewWillDisappear and remove highlighting etc with: revertAndReset()
                
                // Find views that are 'NStackLocalizable'
                for subview in topController.view.subviews {
                    if
                        let translatableItem = subview as? NStackLocalizable,
                        let section = translatableItem.section,
                        let key = translatableItem.key
                    {
                        if let translationsManager = NStack.sharedInstance.translationsManager {
                            if translationsManager.containsComponent(for: section, key: key) {
                                ShakeDetection.translatableSubviews.append(translatableItem)
                            }
                        }
                    }
                }
                
                if !ShakeDetection.translatableSubviews.isEmpty {
                    ShakeDetection.isEditing = true
                    
                    // Handle the editable items
                    for item in ShakeDetection.translatableSubviews {
                        // Save original states
                        item.originalBackgroundColor = item.backgroundColor
                        item.originalIsUserInteractionEnabled = item.isUserInteractionEnabled
                        
                        // Add gesture recognizer
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                        item.addGestureRecognizer(tapGesture)
                        item.isUserInteractionEnabled = true
                        
                        if let view = item.backgroundViewToColor {
                            view.backgroundColor = .yellow
                        }
                    }
                }
                
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if
            let visibleViewController = visibleViewController(),
            let item = sender?.view as? NStackLocalizable
        {
            
            let alertController = UIAlertController(title: item.translatableValue, message: "", preferredStyle: UIAlertController.Style.alert)

            let saveAction = UIAlertAction(title: "Send", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                // Set proposal to label
                item.translatableValue = textField.text
                // Send proposal to API
                if
                    let section = item.section,
                    let key = item.key
                {
                    NStack.sharedInstance.storeProposal(section: section, key: key, value: textField.text ?? "")
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Add proposal here"
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            visibleViewController.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    private func revertAndReset() {
        // Revert to original state
        for item in ShakeDetection.translatableSubviews {
            item.backgroundViewToColor?.backgroundColor = item.originalBackgroundColor
            item.isUserInteractionEnabled = item.originalIsUserInteractionEnabled
            if let lastGesture = item.gestureRecognizers?.last {
                item.removeGestureRecognizer(lastGesture)
            }
        }
        ShakeDetection.translatableSubviews = []
        ShakeDetection.isEditing = false
    }
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return getVisibleViewControllerFrom( vc: visibleController )
            
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return getVisibleViewControllerFrom(vc: selectedTabController )
            
        } else {
            if let presentedViewController = vc.presentedViewController {
                return getVisibleViewControllerFrom(vc: presentedViewController)
                
            } else {
                return vc
            }
        }
    }
}
