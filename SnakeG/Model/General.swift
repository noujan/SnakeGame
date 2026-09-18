//
//  General.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 4/19/22.
//

import Foundation
import SwiftUI

class GeneralInfo: ObservableObject {
    static let initialTickInterval: TimeInterval = 0.1
    static let minTickInterval: TimeInterval = 0.04
    static let speedUpFactor: Double = 0.92

    // Points awarded for the very first piece of food.
    static let basePoints: Int = 10

    // Bonus food is bigger and worth much more than normal food. It spans a
    // `bonusSizeMultiplier`-cell square, spawns on a timer, and disappears again
    // after `bonusLifetime` seconds if the player doesn't grab it in time.
    static let bonusPoints: Int = 50
    static let bonusSizeMultiplier: CGFloat = 2
    static let bonusLifetime: TimeInterval = 6
    static let bonusSpawnInterval: TimeInterval = 10
    static let bonusEmojis = ["🍎", "🍕", "🍔", "🍩", "🍒", "🎁", "⭐️", "💎"]

    @Published var tickInterval: TimeInterval = GeneralInfo.initialTickInterval
    var foodPos = CGPoint(x: 0, y: 0) // the position of the food

    // Centre of the current bonus, or `nil` when no bonus is on the board.
    @Published var bonusPos: CGPoint? = nil
    @Published var bonusEmoji: String = GeneralInfo.bonusEmojis[0]
    // How long the current bonus has been on the board. Tracked in game-tick
    // time (not wall-clock) so it naturally freezes while the game is paused.
    private var bonusAge: TimeInterval = 0
    // A bonus may only spawn after the player eats a normal piece of food.
    // Eating normal food "arms" one bonus; the arm is only consumed when a bonus
    // is actually eaten, so a missed bonus is re-offered until one is collected.
    // Either way the player can collect at most one bonus per normal point.
    private var bonusArmed = false

    /// Picks a random food position on the half-cell grid, always *inside* the
    /// walls, so every piece of food is reachable and aligns with the snake.
    func changeRectPos(snakeSize: CGFloat) -> CGPoint {
        let cols = max(1, Int(boardWidth / snakeSize))
        let rows = max(1, Int(boardHeight / snakeSize))

        let col = Int.random(in: 0..<cols)
        let row = Int.random(in: 0..<rows)

        return cellCenter(col: col, row: row, snakeSize: snakeSize)
    }

    /// A random starting cell that keeps at least one cell of clearance from
    /// every wall, so the snake's first move can never immediately hit a wall
    /// regardless of its starting direction.
    func randomStartPosition(snakeSize: CGFloat) -> CGPoint {
        let cols = max(3, Int(boardWidth / snakeSize))
        let rows = max(3, Int(boardHeight / snakeSize))

        let col = Int.random(in: 1..<(cols - 1))
        let row = Int.random(in: 1..<(rows - 1))

        return cellCenter(col: col, row: row, snakeSize: snakeSize)
    }

    /// The centre point of a grid cell, offset by half a cell so it lines up with
    /// the collision bounds in `Screen.swift`.
    private func cellCenter(col: Int, row: Int, snakeSize: CGFloat) -> CGPoint {
        CGPoint(x: snakeSize / 2 + CGFloat(col) * snakeSize,
                y: snakeSize / 2 + CGFloat(row) * snakeSize)
    }

    /// The faster the snake is moving, the more each piece of food is worth.
    /// At the starting speed this is `basePoints`; it scales up as the game
    /// speeds up, rewarding longer, faster runs.
    func pointsForFood() -> Int {
        let speedMultiplier = GeneralInfo.initialTickInterval / tickInterval
        return Int((Double(GeneralInfo.basePoints) * speedMultiplier).rounded())
    }

    func speedUp() {
        tickInterval = max(GeneralInfo.minTickInterval,
                           tickInterval * GeneralInfo.speedUpFactor)
    }

    // MARK: - Bonus food

    /// The on-screen side length of the bonus square.
    func bonusSize(snakeSize: CGFloat) -> CGFloat {
        snakeSize * GeneralInfo.bonusSizeMultiplier
    }

    /// Places a fresh bonus at a random spot, fully inside the walls and clear of
    /// every position in `occupied` (the snake's body and the normal food). The
    /// bonus spans a 2x2 block of cells, so we keep one extra cell of clearance on
    /// the right and bottom edges, and centre it on the block's shared inner
    /// corner. If the board is too crowded to fit one, no bonus is spawned.
    func spawnBonus(snakeSize: CGFloat, avoiding occupied: [CGPoint]) {
        // Only spawn if the player has earned a bonus by eating normal food, and
        // never stack a second bonus on top of one already on the board.
        guard bonusArmed, bonusPos == nil else { return }

        let cols = max(2, Int(boardWidth / snakeSize))
        let rows = max(2, Int(boardHeight / snakeSize))

        var candidates: [CGPoint] = []
        for col in 0..<(cols - 1) {
            for row in 0..<(rows - 1) {
                let center = CGPoint(x: snakeSize + CGFloat(col) * snakeSize,
                                     y: snakeSize + CGFloat(row) * snakeSize)
                if !occupied.contains(where: { footprint(center: center, contains: $0, snakeSize: snakeSize) }) {
                    candidates.append(center)
                }
            }
        }

        guard let chosen = candidates.randomElement() else { return }
        bonusPos = chosen
        bonusEmoji = GeneralInfo.bonusEmojis.randomElement() ?? GeneralInfo.bonusEmojis[0]
        bonusAge = 0
    }

    /// Makes one bonus eligible to spawn. Called when the player eats normal food.
    func armBonus() {
        bonusArmed = true
    }

    /// Removes an eaten bonus and consumes the arm, so the next bonus requires
    /// eating another normal point first.
    func collectBonus() {
        clearBonus()
        bonusArmed = false
    }

    /// The snake's head eats the bonus when it enters any of the 2x2 cells the
    /// bonus covers, i.e. when it is within one cell of the bonus centre.
    func hitsBonus(head: CGPoint, snakeSize: CGFloat) -> Bool {
        guard let bonusPos else { return false }
        return footprint(center: bonusPos, contains: head, snakeSize: snakeSize)
    }

    /// Whether `point` falls inside the 2x2 footprint centred on `center`.
    private func footprint(center: CGPoint, contains point: CGPoint, snakeSize: CGFloat) -> Bool {
        abs(point.x - center.x) < snakeSize && abs(point.y - center.y) < snakeSize
    }

    /// Points the current bonus is worth, scaled by speed just like normal food.
    func bonusPointsValue() -> Int {
        let speedMultiplier = GeneralInfo.initialTickInterval / tickInterval
        return Int((Double(GeneralInfo.bonusPoints) * speedMultiplier).rounded())
    }

    func clearBonus() {
        bonusPos = nil
        bonusAge = 0
    }

    /// Ages the bonus by one game tick and removes it once it has outlived its
    /// lifetime. Because this is driven by movement ticks (which stop while the
    /// game is paused), a paused bonus keeps its remaining time.
    func ageBonus(by interval: TimeInterval) {
        guard bonusPos != nil else { return }
        bonusAge += interval
        if bonusAge > GeneralInfo.bonusLifetime {
            clearBonus()
        }
    }

    func reset(snakeSize: CGFloat) {
        foodPos = CGPoint(x: 0, y: 0)
        foodPos = changeRectPos(snakeSize: snakeSize)
        tickInterval = GeneralInfo.initialTickInterval
        clearBonus()
        bonusArmed = false
    }
}
