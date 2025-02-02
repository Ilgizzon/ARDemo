//
//  AppDelegate.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 12.10.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: - Put controller to main window
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        return true
    }
}

