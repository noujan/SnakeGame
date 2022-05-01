//
//  Snake.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

class Snake: ObservableObject {
    @Published var startPos : CGPoint = .zero // the start poisition of our swipe
    @Published var isStarted = true // did the user started the swipe?
    @Published var gameOver = false // for ending the game when the snake hits the screen borders
    @Published var dir = direction.down // the direction the snake is going to take
    @Published var posArray = [CGPoint(x: 20, y: 100)] // array of the snake's body positions
    @Published var snakeSize : CGFloat = 10 // width and height of the snake
    @Published var scoreLabel = "score: 0"
    
    var score : Int = 0 {
        didSet{
            scoreLabel = "score: \(score)"
        }
    }
    
    func changeDirection () {
        let posX = posArray[0].x
        let posY = posArray[0].y
        if posX < minX - snakeSize {
            posArray[0] = CGPoint(
                x: (maxX/10).rounded()*10 + snakeSize,
                y: posY
            )
        } else if posX > maxX + snakeSize {
            posArray[0] = CGPoint(
                x: minX - snakeSize,
                y: posY
            )
        } else if posY < minY - snakeSize {
//            print("posY up: \(posY), minY: \(minY)")
            posArray[0] = CGPoint(
                x: posX,
                y: (maxY/10).rounded()*10 + 5 * snakeSize
            )
        } else if posY > maxY + 4 * snakeSize {
//            print("posY down: \(posY), maxY: \((maxY/10).rounded()*10)")
            posArray[0] = CGPoint(
                x: posX,
                y: minY - 2 * snakeSize
            )
        }
        
        var prev = posArray[0]
        if dir == .down {
            posArray[0].y += snakeSize
        } else if dir == .up {
            posArray[0].y -= snakeSize
        } else if dir == .left {
            posArray[0].x += snakeSize
        } else {
            posArray[0].x -= snakeSize
        }
        for index in 1..<posArray.count {
            let current = posArray[index]
            posArray[index] = prev
            prev = current
        }
    }
    
    func getScoreLabel() -> String {
        return scoreLabel
    }
    
    func reset() {
        posArray = [CGPoint(x: 20, y: 100)]
        gameOver = false
        startPos = .zero
        snakeSize = 10
        isStarted = true
        dir = direction.down
    }
}

