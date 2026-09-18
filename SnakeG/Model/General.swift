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

    @Published var tickInterval: TimeInterval = GeneralInfo.initialTickInterval
    var foodPos = CGPoint(x: 0, y: 0) // the position of the food

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

    func reset(snakeSize: CGFloat) {
        foodPos = CGPoint(x: 0, y: 0)
        foodPos = changeRectPos(snakeSize: snakeSize)
        tickInterval = GeneralInfo.initialTickInterval
    }
}
