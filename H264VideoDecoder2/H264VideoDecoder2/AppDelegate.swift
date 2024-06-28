//
//  AppDelegate.swift
//  H264VideoDecoder2
//
//  Created by Ravi Chokshi on 15/06/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
                print("Documents Directory: \(documentsPath)")
            }
        return true
    }

    


}

