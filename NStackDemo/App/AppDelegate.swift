//
//  AppDelegate.swift
//  NStackDemo
//
//  Created by Marius Constantinescu on 15/10/2020.
//

import UIKit
import NStackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNStack(with: launchOptions)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "FeatureListViewController", bundle: nil)
        let featureListViewController: FeatureListViewController = mainStoryboard.instantiateViewController(withIdentifier: "FeatureListViewController") as! FeatureListViewController
        let navigationController = UINavigationController.init(rootViewController: featureListViewController)

        self.window?.rootViewController = navigationController

        self.window?.makeKeyAndVisible()

        return true
    }

    private func setupNStack(with launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) {
        let nstackConfig = Configuration(plistName: "NStack",
                                         environment: .production,     // You can switch here based on your app's current environment
                                         localizationClass: Localizations.self)
        NStack.start(configuration: nstackConfig, launchOptions: launchOptions)
        NStack.sharedInstance.localizationManager?.updateLocalizations()
    }
}

