//
//  SnakeGApp.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Firebase

@main
struct SnakeGApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            GameView()
        }
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        //MARK: Test code to crash the app and make sure Crashlytics is working properly
//        let x: Int? = nil
//        let y = x!
        return true
    }
}
