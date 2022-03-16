//
//  PlayerInfo.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 4/25/21.
//

import Foundation


class Player {
    var uid: String
    var email: String?
    var displayName: String?
    var password: String
    var snake = Snake()
    
    init(uid: String, email: String?, displayName: String?, password: String) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.password = password
    }
}
