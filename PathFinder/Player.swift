//
//  Player.swift
//  Pathfinder
//
//  Created by Andy Monroe on 5/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Player {
    var power: Int
    
    var position: int2
    
    init() {
        power = 5
        position = int2(0,0)
    }
    
    func moveUp() {
        position.y = position.y + 1
    }
    func moveDown() {
        position.y = position.y - 1
    }
    func moveLeft() {
        position.x = position.x - 1
    }
    func moveRight() {
        position.x = position.x + 1
    }
    func moveToPosition(newPosition: int2) {
        position = newPosition
    }
}
