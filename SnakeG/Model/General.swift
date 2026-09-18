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
    static let bonusEmojis = ["🍎", "🍕", "🍔", "🍩", "🍒", "🎁", "⭐️", "💎"]

    @Published var tickInterval: TimeInterval = GeneralInfo.initialTickInterval
    var foodPos = CGPoint(x: 0, y: 0) // the position of the food

    // Centre of the current bonus, or `nil` when no bonus is on the board.
    @Published var bonusPos: CGPoint? = nil
    @Published var bonusEmoji: String = GeneralInfo.bonusEmojis[0]
    private var bonusSpawnedAt: Date?

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

    /// Places a fresh bonus at a random spot, fully inside the walls. The bonus
    /// spans a 2x2 block of cells, so we keep one extra cell of clearance on the
    /// right and bottom edges, and centre it on the block's shared inner corner.
    func spawnBonus(snakeSize: CGFloat) {
        let cols = max(2, Int(boardWidth / snakeSize))
        let rows = max(2, Int(boardHeight / snakeSize))

        let col = Int.random(in: 0..<(cols - 1))
        let row = Int.random(in: 0..<(rows - 1))

        bonusPos = CGPoint(x: snakeSize + CGFloat(col) * snakeSize,
                           y: snakeSize + CGFloat(row) * snakeSize)
        bonusEmoji = GeneralInfo.bonusEmojis.randomElement() ?? GeneralInfo.bonusEmojis[0]
        bonusSpawnedAt = Date()
    }

    /// The snake's head eats the bonus when it enters any of the 2x2 cells the
    /// bonus covers, i.e. when it is within one cell of the bonus centre.
    func hitsBonus(head: CGPoint, snakeSize: CGFloat) -> Bool {
        guard let bonusPos else { return false }
        return abs(head.x - bonusPos.x) < snakeSize && abs(head.y - bonusPos.y) < snakeSize
    }

    /// Points the current bonus is worth, scaled by speed just like normal food.
    func bonusPointsValue() -> Int {
        let speedMultiplier = GeneralInfo.initialTickInterval / tickInterval
        return Int((Double(GeneralInfo.bonusPoints) * speedMultiplier).rounded())
    }

    func clearBonus() {
        bonusPos = nil
        bonusSpawnedAt = nil
    }

    /// Removes the bonus once it has been on the board longer than its lifetime.
    func expireBonusIfNeeded() {
        guard bonusPos != nil, let bonusSpawnedAt else { return }
        if Date().timeIntervalSince(bonusSpawnedAt) > GeneralInfo.bonusLifetime {
            clearBonus()
        }
    }

    func reset(snakeSize: CGFloat) {
        foodPos = CGPoint(x: 0, y: 0)
        foodPos = changeRectPos(snakeSize: snakeSize)
        tickInterval = GeneralInfo.initialTickInterval
        clearBonus()
    }
}
