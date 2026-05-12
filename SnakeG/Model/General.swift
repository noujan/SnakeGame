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

    @Published var tickInterval: TimeInterval = GeneralInfo.initialTickInterval
    var foodPos = CGPoint(x: 0, y: 0) // the position of the food

    func changeRectPos(snakeSize: CGFloat) -> CGPoint {
        let rows = Int(maxX/snakeSize)
        let cols = Int(maxY/snakeSize)

        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)

        return CGPoint(x: randomX, y: randomY)
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

