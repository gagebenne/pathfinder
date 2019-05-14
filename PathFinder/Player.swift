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
    
    var score: Float = 100.0
    
    var pathTraversed: [GKGridGraphNode] = []
    var treasuresFound: [GKGridGraphNode] = []
    var enemiesEncountered: [GKGridGraphNode] = []
    
    
    init() {
        position = int2(0,0)
    }
    
    init(position: int2) {
        self.position = position
    }
    
    func move(to: GKGridGraphNode) {
        position = int2(to.gridPosition.x, to.gridPosition.y)
        pathTraversed.append(to)
        score = score - 1
    }
    
    func foundTreasure(at: GKGridGraphNode, scoreChange: Float) {
        treasuresFound.append(at)
        score = score + scoreChange
    }
    
    func encounteredEnemy(at: GKGridGraphNode, scoreChange: Float) {
        enemiesEncountered.append(at)
        score = score + scoreChange
    }
}
