//
//  Snake.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

class Snake: ObservableObject {
    private static let highScoreKey = "snakeg.highScore"

    @Published var startPos : CGPoint = .zero // the start poisition of our swipe
    @Published var isStarted = true // did the user started the swipe?
    @Published var gameOver = false // for ending the game when the snake hits the screen borders
    @Published var dir = direction.down // the direction the snake is going to take
    @Published var posArray = [CGPoint(x: 20, y: 100)] // array of the snake's body positions
    @Published var snakeSize : CGFloat = snakeUnit // width and height of the snake
    @Published var scoreLabel = "Score: 0"
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: Snake.highScoreKey)

    var score : Int = 0 {
        didSet {
            scoreLabel = "Score: \(score)"
        }
    }

    /// Advances the snake one cell in its current direction. Hitting a wall ends
    /// the game (classic Nokia behaviour) instead of wrapping around, which fixes
    /// the snake appearing on two edges at once.
    func changeDirection () {
        var head = posArray[0]

        switch dir {
        case .down:  head.y += snakeSize
        case .up:    head.y -= snakeSize
        case .right: head.x += snakeSize
        case .left:  head.x -= snakeSize
        }

        // The snake died against a wall.
        if head.x < minX || head.x > maxX || head.y < minY || head.y > maxY {
            gameOver = true
            return
        }

        // Move the body: every segment takes the position of the one ahead of it.
        var prev = posArray[0]
        posArray[0] = head
        for index in 1..<posArray.count {
            let current = posArray[index]
            posArray[index] = prev
            prev = current
        }
    }

    /// Adds points for eating food and keeps the persisted high score in sync.
    func award(points: Int) {
        score += points
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: Snake.highScoreKey)
        }
    }

    func getScoreLabel() -> String {
        return scoreLabel
    }

    func reset() {
        posArray = [CGPoint(x: 20, y: 100)]
        gameOver = false
        startPos = .zero
        snakeSize = snakeUnit
        isStarted = true
        dir = direction.down
        score = 0
    }
}
