//
//  GameCenterManager.swift
//  SnakeG
//
//  Handles Game Center authentication and submitting the player's score to a
//  leaderboard so results are saved with GameKit.
//

import Foundation
import GameKit
import SwiftUI

@MainActor
final class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()

    /// Leaderboard identifier configured in App Store Connect for high scores.
    static let leaderboardID = "Snake"

    @Published private(set) var isAuthenticated = false

    private init() {}

    /// Authenticates the local player with Game Center. Presents the sign-in UI
    /// if needed. Safe to call multiple times.
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                // Game Center needs the player to sign in — present its UI.
                Self.present(viewController)
                return
            }

            if let error = error {
                print("Game Center authentication failed: \(error.localizedDescription)")
                Task { @MainActor in self?.isAuthenticated = false }
                return
            }

            Task { @MainActor in
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
            }
        }
    }

    /// Submits a score to the leaderboard. No-op if the player isn't signed in.
    func submit(score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Skipping score submission: Game Center player not authenticated")
            return
        }

        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [Self.leaderboardID]
                )
            } catch {
                print("Failed to submit score to Game Center: \(error.localizedDescription)")
            }
        }
    }

    /// Presents the Game Center leaderboard UI. If the player isn't signed in to
    /// Game Center yet, this kicks off authentication instead (the leaderboard
    /// can't load without an authenticated player, which shows "Cannot Connect").
    func showLeaderboard() {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Cannot show leaderboard: player not authenticated. Retrying authentication.")
            authenticate()
            return
        }

        guard let root = Self.topViewController() else { return }

        let viewController = GKGameCenterViewController(
            leaderboardID: Self.leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        viewController.gameCenterDelegate = GameCenterDelegate.shared
        root.present(viewController, animated: true)
    }

    // MARK: - UIKit presentation helpers

    private static func present(_ viewController: UIViewController) {
        guard let root = topViewController() else { return }
        root.present(viewController, animated: true)
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        guard var top = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

/// Dismisses the Game Center overlay when the player is done with it.
final class GameCenterDelegate: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDelegate()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
