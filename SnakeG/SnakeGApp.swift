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
            SnakeGameView()
        }
        
    }
    
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
        }
    }
}
