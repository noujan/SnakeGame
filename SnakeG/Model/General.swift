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

    /// Picks a random food position that always lands on the grid *inside* the
    /// walls, so every piece of food is reachable.
    func changeRectPos(snakeSize: CGFloat) -> CGPoint {
        let minCol = Int(minX / snakeSize)
        let maxCol = Int(maxX / snakeSize)
        let minRow = Int(minY / snakeSize)
        let maxRow = Int(maxY / snakeSize)

        let randomX = Int.random(in: minCol...maxCol) * Int(snakeSize)
        let randomY = Int.random(in: minRow...maxRow) * Int(snakeSize)

        return CGPoint(x: randomX, y: randomY)
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
