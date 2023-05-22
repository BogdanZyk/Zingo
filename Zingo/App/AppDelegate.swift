//
//  AppDelegate.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//


import Foundation
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    
//    var appEnvironment: AppEnvironment!
    
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
//        self.appEnvironment = AppEnvironment()
        return true
    }
    

    
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
//                     -> Void) {
////        appEnvironment.appDidReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
//    }
    
//    func application(_ application: UIApplication,
//                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Unable to register for remote notifications: \(error.localizedDescription)")
//    }
//
//
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("APNs token retrieved: \(deviceToken)")
//    }
}
