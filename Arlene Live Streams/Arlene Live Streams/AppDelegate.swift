//
//  AppDelegate.swift
//  Arlene Live Streams
//
//  Created by Hermes on 2/5/20.
//  Copyright © 2020 Hermes. All rights reserved.
//

import UIKit
import ARVideoKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .light
        }
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return ViewAR.orientation
    }


}


