//
//  SnakeGApp.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Firebase
import GameKit
import UIKit

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
        GameCenterManager.shared.authenticateUser()
        //MARK: Test code to crash the app and make sure Crashlytics is working properly
        //        let x: Int? = nil
        //        let y = x!
        return true
    }
}

final class GameCenterManager: NSObject {
    static let shared = GameCenterManager()

    private let leaderboardIdentifier = "snakeg_leaderboard"
    private var isAuthenticated = false

    private override init() {
        super.init()
    }

    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let authenticationVC = viewController {
                self?.presentGameCenter(authenticationVC)
            } else if let error = error {
                print("Game Center authentication error: \(error.localizedDescription)")
            } else {
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
            }
        }
    }

    func submit(score: Int) {
        guard isAuthenticated else {
            print("Game Center score submission skipped: player not authenticated")
            return
        }

        let scoreReporter = GKScore(leaderboardIdentifier: leaderboardIdentifier)
        scoreReporter.value = Int64(score)

        GKScore.report([scoreReporter]) { error in
            if let error = error {
                print("Failed to report score to Game Center: \(error.localizedDescription)")
            } else {
                print("Successfully reported score \(score) to Game Center")
            }
        }
    }

    private func presentGameCenter(_ viewController: UIViewController) {
        guard let rootViewController = Self.rootViewController() else {
            return
        }

        DispatchQueue.main.async {
            if rootViewController.presentedViewController == nil {
                rootViewController.present(viewController, animated: true)
            }
        }
    }

    private static func rootViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { scene in
                (scene as? UIWindowScene)?.windows.first { $0.isKeyWindow }
            }
            .first?.rootViewController
    }
}
