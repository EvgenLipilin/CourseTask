//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let dataManager: CoreDataInstagram = CoreDataManager(modelName: "instaApp")
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let rootVC = AutorizationViewController()
        rootVC.dataManager = dataManager
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate {
    static let storyboardName = "Storyboard"
    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
}
