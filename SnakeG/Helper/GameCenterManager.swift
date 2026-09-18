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

    // Work that arrived before Game Center finished authenticating. It is flushed
    // once authentication succeeds so nothing is silently dropped.
    private var pendingScore: Int?
    private var pendingLeaderboardRequest = false

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
                if GKLocalPlayer.local.isAuthenticated {
                    self?.flushPendingWork()
                }
            }
        }
    }

    /// Submits a score to the leaderboard. If the player isn't authenticated yet,
    /// the (best) score is queued and submitted once authentication completes.
    func submit(score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Queuing score until Game Center authentication completes")
            pendingScore = max(pendingScore ?? Int.min, score)
            authenticate()
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

    /// Runs any work that was waiting on authentication.
    private func flushPendingWork() {
        if let score = pendingScore {
            pendingScore = nil
            submit(score: score)
        }
        if pendingLeaderboardRequest {
            pendingLeaderboardRequest = false
            showLeaderboard()
        }
    }

    /// Presents the Game Center leaderboard UI. If the player isn't signed in to
    /// Game Center yet, this remembers the request and presents the leaderboard
    /// automatically once authentication succeeds (instead of the player having
    /// to tap the button a second time).
    func showLeaderboard() {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Deferring leaderboard: player not authenticated. Authenticating first.")
            pendingLeaderboardRequest = true
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

    // The app is single-scene (UIApplicationSupportsMultipleScenes = false), so
    // the first foreground-active scene is always the one that initiated the request.
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
