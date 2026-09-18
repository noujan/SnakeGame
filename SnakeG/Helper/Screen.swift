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
//
// These are computed once from `UIScreen`. That is safe because the app is
// locked to portrait, single-scene, full-screen (see Info.plist), so the board
// dimensions never change at runtime.
let boardWidth: CGFloat = (floor((UIScreen.main.bounds.width - boardHorizontalPadding * 2) / snakeUnit)) * snakeUnit
let boardHeight: CGFloat = (floor((UIScreen.main.bounds.height - boardTopReserved) / snakeUnit)) * snakeUnit

// Valid range for a snake/food cell *centre* inside the board (in the board's own
// coordinate space, where 0,0 is the top-left corner). `.position` places the
// centre of each cell, so the outermost centres sit half a cell from the edge;
// this makes the snake visually touch the wall right before it dies.
let minX = snakeUnit / 2
let minY = snakeUnit / 2
let maxX = boardWidth - snakeUnit / 2
let maxY = boardHeight - snakeUnit / 2

public enum direction {
    case up, down, left, right
}
