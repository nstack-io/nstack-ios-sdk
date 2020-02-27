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
        static var canDisplayBottomPopup = true
        static var proposalBottomPopupView: UIView?
        static var localizableSubviews: [NStackLocalizable] = []
        static var flowSubviews: [UIView] = []
        static var currentItem: NStackLocalizable?
    }

    enum Sender: Int {
        case openAllProposals = 0
        case openProposalsForKey = 1
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
            dismissFlow()
            return
        }

        if let topController = visibleViewController {
            // TODO: Observe for viewWillDisappear and remove highlighting etc with: revertAndReset()

            appendLocalizableSubviews(for: topController)

            if !ShakeDetection.localizableSubviews.isEmpty {
                ShakeDetection.isEditing = true

                // Handle the editable items
                for item in ShakeDetection.localizableSubviews {
                    // Save original states
                    item.originalBackgroundColor = item.backgroundColor
                    item.originalIsUserInteractionEnabled = item.isUserInteractionEnabled

                    // Add gesture recognizer
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                    item.addGestureRecognizer(tapGesture)
                    item.isUserInteractionEnabled = true

                    if let view = item.backgroundViewToColor {
                        view.backgroundColor = .yellow
                    }
                }
            }
        }
    }

    private func appendLocalizableSubviews(for viewController: UIViewController) {
        // Find views that are ´NStackLocalizable´ and has a section and key value that has been translated
        ShakeDetection.localizableSubviews = viewController.view.subviews
            .map { currentView in
                guard let translationsManager = NStack.sharedInstance.localizationManager else { return nil }

                guard
                    let translatableItem = currentView as? NStackLocalizable,
                    let identifier = translatableItem.localizationItemIdentifier
                else {
                    return nil
                }
                return translationsManager.containsComponent(for: identifier) ? translatableItem : nil
            }
            .compactMap { $0 }
    }

    @objc
    func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if
            let visibleViewController = visibleViewController,
            let item = sender?.view as? NStackLocalizable {
            startFlow(for: item, in: visibleViewController)
        }
    }

    // Revert to original state
    private func revertAndReset() {
        for item in ShakeDetection.localizableSubviews {
            item.backgroundViewToColor?.backgroundColor = item.originalBackgroundColor
            item.isUserInteractionEnabled = item.originalIsUserInteractionEnabled
            if let lastGesture = item.gestureRecognizers?.last {
                item.removeGestureRecognizer(lastGesture)
            }
        }
        ShakeDetection.localizableSubviews = []
        ShakeDetection.isEditing = false

        displayBottomPopup()
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
            let visibleController = navigationController.visibleViewController {
            return getVisibleViewControllerFrom(vc: visibleController)
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return getVisibleViewControllerFrom(vc: selectedTabController)
        } else {
            if let presentedViewController = vc.presentedViewController {
                return getVisibleViewControllerFrom(vc: presentedViewController)

            } else {
                return vc
            }
        }
    }

    // MARK: - UI / Flow

    // Displays the first view in the proposal flow
    private func startFlow(for item: NStackLocalizable, in viewController: UIViewController) {
        ShakeDetection.currentItem = item

        // Dimm background
        let dimmedBackground = UIView(frame: bounds)
        dimmedBackground.backgroundColor = UIColor(white: 0, alpha: 0.35)
        ShakeDetection.flowSubviews.append(dimmedBackground)
        addSubview(dimmedBackground)
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFlow))
        dimmedBackground.addGestureRecognizer(dismissTapGesture)

        // Create main view
        let screenSize: CGRect = UIScreen.main.bounds
        let proposalLaunchView = UIView(frame: CGRect(x: screenSize.midX, y: screenSize.midY, width: screenSize.width - 50, height: screenSize.height / 4))
        proposalLaunchView.frame.origin.x = viewController.view.bounds.midX - proposalLaunchView.bounds.midX
        proposalLaunchView.frame.origin.y = viewController.view.bounds.midY - proposalLaunchView.bounds.midY
        ShakeDetection.flowSubviews.append(proposalLaunchView)
        addSubview(proposalLaunchView)
        proposalLaunchView.backgroundColor = .white

        let label = UILabel()
        proposalLaunchView.addSubview(label)
        label.text = "NStack proposal"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: proposalLaunchView.topAnchor, constant: 25).isActive = true
        label.leadingAnchor.constraint(equalTo: proposalLaunchView.leadingAnchor, constant: 25).isActive = true

        let proposeButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        proposalLaunchView.addSubview(proposeButton)
        proposeButton.setTitleColor(.blue, for: .normal)
        proposeButton.setTitle("Propose new translation", for: .normal)
        proposeButton.addTarget(self, action: #selector(proposeNewTranslationClicked), for: .touchUpInside)
        proposeButton.translatesAutoresizingMaskIntoConstraints = false
        proposeButton.bottomAnchor.constraint(equalTo: proposalLaunchView.bottomAnchor, constant: -15).isActive = true
        proposeButton.trailingAnchor.constraint(equalTo: proposalLaunchView.trailingAnchor, constant: -25).isActive = true

        let viewProposalsButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        proposalLaunchView.addSubview(viewProposalsButton)
        viewProposalsButton.setTitleColor(.blue, for: .normal)
        viewProposalsButton.tag = Sender.openProposalsForKey.rawValue
        viewProposalsButton.setTitle("View translation proposals", for: .normal)
        viewProposalsButton.addTarget(self, action: #selector(viewLocalizationProposalsClicked), for: .touchUpInside)
        viewProposalsButton.translatesAutoresizingMaskIntoConstraints = false
        viewProposalsButton.bottomAnchor.constraint(equalTo: proposeButton.topAnchor).isActive = true
        viewProposalsButton.trailingAnchor.constraint(equalTo: proposalLaunchView.trailingAnchor, constant: -25).isActive = true
    }

    @objc
    private func dismissFlow() {
        for flowSubview in ShakeDetection.flowSubviews {
            flowSubview.removeFromSuperview()
        }
        ShakeDetection.flowSubviews.removeAll()
    }

    private func displayBottomPopup() {
        if ShakeDetection.canDisplayBottomPopup {
            ShakeDetection.canDisplayBottomPopup = false
            if let viewController = visibleViewController {
                ShakeDetection.proposalBottomPopupView = UIView(frame: CGRect(x: viewController.view.bounds.minX, y: viewController.view.bounds.maxY, width: viewController.view.bounds.width, height: 60))
                guard let proposalBottomPopup = ShakeDetection.proposalBottomPopupView else { return }
                addSubview(proposalBottomPopup)
                proposalBottomPopup.backgroundColor = .gray
                proposalBottomPopup.alpha = 0

                let label = UILabel()
                proposalBottomPopup.addSubview(label)
                label.text = "Open proposals"
                label.translatesAutoresizingMaskIntoConstraints = false
                label.centerYAnchor.constraint(equalTo: proposalBottomPopup.centerYAnchor).isActive = true
                label.leadingAnchor.constraint(equalTo: proposalBottomPopup.leadingAnchor, constant: 20).isActive = true

                let viewProposalsButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
                proposalBottomPopup.addSubview(viewProposalsButton)
                viewProposalsButton.setTitleColor(.blue, for: .normal)
                viewProposalsButton.tag = Sender.openAllProposals.rawValue
                viewProposalsButton.setTitle("Open", for: .normal)
                viewProposalsButton.addTarget(self, action: #selector(viewLocalizationProposalsClicked), for: .touchUpInside)
                viewProposalsButton.translatesAutoresizingMaskIntoConstraints = false
                viewProposalsButton.centerYAnchor.constraint(equalTo: proposalBottomPopup.centerYAnchor).isActive = true
                viewProposalsButton.trailingAnchor.constraint(equalTo: proposalBottomPopup.trailingAnchor, constant: -20).isActive = true

                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear],
                               animations: {
                                   proposalBottomPopup.alpha = 1
                                   proposalBottomPopup.center.y -= proposalBottomPopup.bounds.height
                                   proposalBottomPopup.layoutIfNeeded()
                               }, completion: { (_: Bool) -> Void in
                                   // dismiss after 3 seconds if no interaction
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                       self.hideBottomPopup()
                                   }
                })
            }
        }
    }

    private func hideBottomPopup() {
        guard let proposalBottomPopup = ShakeDetection.proposalBottomPopupView else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear],
                       animations: {
                           proposalBottomPopup.alpha = 0
                           proposalBottomPopup.center.y += proposalBottomPopup.bounds.height
                           proposalBottomPopup.layoutIfNeeded()

                       }, completion: { (_: Bool) -> Void in
                           proposalBottomPopup.removeFromSuperview()
                           ShakeDetection.canDisplayBottomPopup = true
        })
    }

    // MARK: Flow button actions

    // Opens the alertview to enter a new translation proposal into
    @objc
    func proposeNewTranslationClicked() {
        if let visibleViewController = visibleViewController, let item = ShakeDetection.currentItem {
            let alertController = UIAlertController(title: item.localizableValue, message: "", preferredStyle: UIAlertController.Style.alert)

            let saveAction = UIAlertAction(title: "Send", style: UIAlertAction.Style.default, handler: { _ -> Void in
                let textField = alertController.textFields![0] as UITextField
                if textField.text != "" {
                    // Set proposal to label
                    item.localizableValue = textField.text
                    // Send proposal to API
                    if let identifier = item.localizationItemIdentifier {
                        NStack.sharedInstance.storeProposal(for: identifier, with: textField.text ?? "", completion: { error in
                            self.showConfirmationAlert(text: error?.localizedDescription ?? "Proposal Stored")
                            })
                    }
                }
                })

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (_: UIAlertAction!) -> Void in
                // Start flow again
                guard let currentItem = ShakeDetection.currentItem else { return }
                self.startFlow(for: currentItem, in: visibleViewController)
                })

            alertController.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "Add proposal here"
            }

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            dismissFlow()
            visibleViewController.present(alertController, animated: true, completion: nil)
        }
    }

    func showConfirmationAlert(text: String) {
        if let visibleViewController = visibleViewController {
            let alertController = UIAlertController(title: text, message: "", preferredStyle: UIAlertController.Style.alert)

            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(okAction)
            visibleViewController.present(alertController, animated: true, completion: nil)
        }
    }

    // Opens the listview of all localization for the given key
    @objc
    func viewLocalizationProposalsClicked(sender: UIButton) {
        if let visibleViewController = visibleViewController {
            NStack.sharedInstance.fetchProposals { proposals in
                DispatchQueue.main.async {
                    self.dismissFlow()
                    self.hideBottomPopup()

                    guard let proposals = proposals else {
                        #warning("present error message here")
                        return
                    }

                    // Present list vc
                    let proposalNav = UINavigationController()
                    proposalNav.modalPresentationStyle = .overFullScreen
                    let interactor = ProposalInteractor(nstackSharedInstance: NStack.sharedInstance)

                    let listingAllProposals = sender.tag == Sender.openAllProposals.rawValue

                    let presenter = ProposalPresenter(interactor: interactor,
                                                      proposals: proposals,
                                                      listingAllProposals: listingAllProposals,
                                                      currentItem: listingAllProposals ? nil : ShakeDetection.currentItem)

                    let proposalVC = ProposalViewController()
                    proposalVC.instantiate(with: presenter)
                    proposalNav.viewControllers = [proposalVC]

                    interactor.output = presenter
                    presenter.output = proposalVC

                    visibleViewController.present(proposalNav, animated: true, completion: nil)
                }
            }
        }
    }
}
