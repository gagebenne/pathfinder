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
    var position: int2
    
    var score: Int
    
    var pathTraversed: [GKGridGraphNode] = []
    var treasuresFound: [GKGridGraphNode] = []
    var enemiesEncountered: [GKGridGraphNode] = []
    
    
    init() {        
        position = int2(0,0)
        score = 0
    }
    
    func move(to: GKGridGraphNode) {
        position = int2(to.gridPosition.x, to.gridPosition.y)
        pathTraversed.append(to)
    }
    
    func foundTreasure(at: GKGridGraphNode) {
        treasuresFound.append(at)
    }
    
    func encounteredEnemy(at: GKGridGraphNode) {
        enemiesEncountered.append(at)
    }
    
    func updateScore() {
        score = pathTraversed.count - 10*treasuresFound.count + 10*enemiesEncountered.count
    }
}
