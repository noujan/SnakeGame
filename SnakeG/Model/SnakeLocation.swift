//
//  SnakeLocation.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

class Snake {
    var startPos : CGPoint = .zero // the start poisition of our swipe
    var isStarted = true // did the user started the swipe?
    var gameOver = false // for ending the game when the snake hits the screen borders
    var dir = direction.down // the direction the snake is going to take
    var posArray = [CGPoint(x: 20, y: 100)] // array of the snake's body positions
    var snakeSize : CGFloat = 10 // width and height of the snake
    var scoreLabel = "score: 0"

    var score : Int = 0 {
        didSet{
            scoreLabel = "score: \(score)"
        }
    }
}

enum direction {
    case up, down, left, right
}

class GeneralInfo {
    var timerOneSec = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    var timePassed = 0
    var foodPos = CGPoint(x: 0, y: 0) // the position of the food

}
