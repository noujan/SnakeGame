//
//  Screen.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 11/28/21.
//

import Foundation
import SwiftUI

let width = UIScreen.main.bounds.width
let height = UIScreen.main.bounds.height
    let minX = CGFloat(20)
let maxX = UIScreen.main.bounds.maxX - 60
let minY = CGFloat(20)
let maxY = UIScreen.main.bounds.maxY - 220

public enum direction {
    case up, down, left, right
}
