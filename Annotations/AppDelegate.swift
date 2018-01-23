//
//  AppDelegate.swift
//  Annotations
//
//  Created by Suyeol Jeon on 23/01/2018.
//  Copyright © 2018 Suyeol Jeon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    window.makeKeyAndVisible()

    let viewController = ViewController()
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.isToolbarHidden = false
    window.rootViewController = navigationController

    self.window = window
    return true
  }
}
