//
//  General.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 4/19/22.
//

import Foundation
import SwiftUI

class GeneralInfo: ObservableObject {
    var timePassed = 0
    var foodPos = CGPoint(x: 0, y: 0) // the position of the food
    
    func changeRectPos(snakeSize: CGFloat) -> CGPoint {
        let rows = Int(maxX/snakeSize)
        let cols = Int(maxY/snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    func reset(snakeSize: CGFloat) {
        foodPos = CGPoint(x: 0, y: 0)
        foodPos = changeRectPos(snakeSize: snakeSize)
    }
}

