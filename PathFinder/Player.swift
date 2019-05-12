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
}
