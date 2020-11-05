//
//  AlertViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 05.11.20.
//

import UIKit
import NStackSDK
import LocalizationManager

class AlertViewController: UIViewController {

    @IBOutlet weak var defaultAlertButton: UIButton! {
        didSet {
            defaultAlertButton.setTitle(tr.alert.defaultAlert, for: .normal)
        }
    }

    @IBOutlet weak var infoAlertButton: UIButton! {
        didSet {
            infoAlertButton.setTitle(tr.alert.infoAlert, for: .normal)
        }
    }

    @IBOutlet weak var openUrlAlertButton: UIButton! {
        didSet {
            openUrlAlertButton.setTitle(tr.alert.openUrlAlert, for: .normal)
        }
    }

    @IBOutlet weak var ratingPromptAlertButton: UIButton! {
        didSet {
            ratingPromptAlertButton.setTitle(tr.alert.ratingPromptAlert, for: .normal)
        }
    }

    @IBOutlet weak var hideAlertButtton: UIButton! {
        didSet {
            hideAlertButtton.setTitle(tr.alert.hideAlert, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = tr.alert.alertTypesTitle
    }

    @IBAction func defaultAlertButtonTapped(_ sender: Any) {
        NStack.sharedInstance.alertManager.showAlertBlock(.updateAlert(title: tr.alert.alertTitle, text: tr.alert.alertSubtitle, dismissButtonText: tr.defaultSection.cancel, appStoreButtonText: tr.defaultSection.ok, completion: { (isOkPressed) in
            print("isOkPressed : \(isOkPressed)")
        }))
    }

    
    @IBAction func infoAlertButtonTapped(_ sender: Any) {
        NStack.sharedInstance.alertManager.showAlertBlock(.whatsNewAlert(title: tr.alert.alertTitle, text: tr.alert.alertSubtitle, dismissButtonText: tr.defaultSection.cancel, completion: {
            print("Completed")
        }))
    }

    @IBAction func openUrlAlertButtonTapped(_ sender: Any) {
        NStack.sharedInstance.alertManager.showAlertBlock(.message(text: tr.alert.alertTitle, url: URL(string: tr.alert.url), dismissButtonText: tr.defaultSection.cancel, openButtonText: tr.alert.openUrl, completion: {
            print("Url Opened - \(tr.alert.url)")
        }))
    }

    @IBAction func ratingPromptAlertButtonTapped(_ sender: Any) {
        NStack.sharedInstance.alertManager.requestReview()
    }

    
    @IBAction func hideAlertButttonTapped(_ sender: Any) {
        NStack.sharedInstance.alertManager.showAlertBlock(.whatsNewAlert(title: tr.alert.alertTitle, text: tr.alert.hideAlertSubtitle, dismissButtonText: tr.defaultSection.cancel, completion: {
        }))

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if NStack.sharedInstance.alertManager.alreadyShowingAlert {
                NStack.sharedInstance.alertManager.hideAlertWindow()
            }
        }
    }
    
}
