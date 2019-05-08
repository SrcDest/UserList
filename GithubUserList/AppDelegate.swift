//
//  AppDelegate.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewController = ViewController()
        viewController.view.backgroundColor = .white
        
        window = UIWindow()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
}

