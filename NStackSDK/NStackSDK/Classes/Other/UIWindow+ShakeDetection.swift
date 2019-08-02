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
        static var flowSubviews: [UIView] = []
    }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if !NStack.sharedInstance.configuration.isProduction {
            switch motion {
            case .motionShake:
                handleShake()
            default:
                break
            }
        }
    }

    private func handleShake() {
        if ShakeDetection.isEditing {
            revertAndReset()
            return
        }
        
        if let topController = visibleViewController {
            // TODO: Observe for viewWillDisappear and remove highlighting etc with: revertAndReset()
            appendTranslatableSubviews(for: topController)
            
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
    
    private func appendTranslatableSubviews(for viewController: UIViewController) {
        // Find views that are ´NStackLocalizable´ and has a section and key value that has been translated
        ShakeDetection.translatableSubviews = viewController.view.subviews
            .map({ currentView in
                guard let translationsManager = NStack.sharedInstance.translationsManager else { return nil }
            
                guard
                    let translatableItem = currentView as? NStackLocalizable,
                    let identifier = translatableItem.translationIdentifier
                else {
                    return nil
                }
                return translationsManager.containsComponent(for: identifier) ? translatableItem : nil
            })
            .compactMap({ return $0})
    }
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if
            let visibleViewController = visibleViewController,
            let item = sender?.view as? NStackLocalizable
        {
            startFlow(for: item, in: visibleViewController)
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
    
    // MARK: - Helpers
    
    var visibleViewController: UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return getVisibleViewControllerFrom(vc: visibleController )
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
    
    // MARK: - Flow
    
    private func startFlow(for item: NStackLocalizable, in viewController: UIViewController) {
        
        // Dimm background
        let dimmedBackground = UIView(frame: self.bounds)
        dimmedBackground.backgroundColor = UIColor(white: 0, alpha: 0.35)
        ShakeDetection.flowSubviews.append(dimmedBackground)
        self.addSubview(dimmedBackground)
        
        // Create main view
        let screenSize: CGRect = UIScreen.main.bounds
        let proposalLaunchView = UIView(frame: CGRect(x: screenSize.midX, y: screenSize.midY, width: screenSize.width - 50, height: screenSize.height / 4))
        proposalLaunchView.frame.origin.x = viewController.view.bounds.midX - proposalLaunchView.bounds.midX
        proposalLaunchView.frame.origin.y = viewController.view.bounds.midY - proposalLaunchView.bounds.midY
        proposalLaunchView.backgroundColor = .white
        
//        let button:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
//        button.backgroundColor = .black
//        button.setTitle("Button", for: .normal)
//        button.addTarget(self, action:#selector(self.proposeNewTranslationClicked(for: item)), for: .touchUpInside)
//        proposalLaunchView.addSubview(button)
        
        ShakeDetection.flowSubviews.append(proposalLaunchView)
        dimmedBackground.addSubview(proposalLaunchView)
    }
    
    private func closeFlow() {
        // TODO: Remove all subviews matching ShakeDetection.flowSubviews
    }
    
    // MARK: Flow button actions
    
    @objc func proposeNewTranslationClicked(for item: NStackLocalizable) {
        if let visibleViewController = visibleViewController {
            let alertController = UIAlertController(title: item.translatableValue, message: "", preferredStyle: UIAlertController.Style.alert)
            
            let saveAction = UIAlertAction(title: "Send", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                // Set proposal to label
                item.translatableValue = textField.text
                // Send proposal to API
                if let identifier = item.translationIdentifier {
                    NStack.sharedInstance.storeProposal(for: identifier, with: textField.text ?? "")
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
}
