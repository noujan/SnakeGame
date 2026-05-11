//
//  SnakeGApp.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct SnakeGApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            GameView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }

    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // Restore the previous Google sign-in if there was one.
        GIDSignIn.sharedInstance.restorePreviousSignIn { _, _ in }
        //MARK: Test code to crash the app and make sure Crashlytics is working properly
        //        let x: Int? = nil
        //        let y = x!
        return true
    }
}
