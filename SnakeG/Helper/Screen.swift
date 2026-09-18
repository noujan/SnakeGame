//
//  Screen.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

// The size of a single snake/food cell. Everything on the board snaps to this grid.
let snakeUnit: CGFloat = 10

let width = UIScreen.main.bounds.width
let height = UIScreen.main.bounds.height

// Space reserved around the play area.
private let boardHorizontalPadding: CGFloat = 20 // .padding on each side of the board
private let boardTopReserved: CGFloat = 200      // pause button + score row + paddings

// The play area is given an explicit, grid-aligned size so that the drawn board
// and the collision walls are exactly the same rectangle. This fixes the snake
// dying a cell early (the old bounds didn't line up with the visible board).
let boardWidth: CGFloat = (floor((UIScreen.main.bounds.width - boardHorizontalPadding * 2) / snakeUnit)) * snakeUnit
let boardHeight: CGFloat = (floor((UIScreen.main.bounds.height - boardTopReserved) / snakeUnit)) * snakeUnit

// Valid range for a snake/food cell centre inside the board (in the board's own
// coordinate space, where 0,0 is the top-left corner).
let minX = snakeUnit
let minY = snakeUnit
let maxX = boardWidth - snakeUnit
let maxY = boardHeight - snakeUnit

public enum direction {
    case up, down, left, right
}
