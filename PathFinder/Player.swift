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

struct PlayerConstants {
    /// Cost of moving one space.
    static let reward = Float(-1.0)
}

class Player {
    // MARK: Properties
    
    /// The players position in a 2D space.
    var position: int2
    
    /// The players current score
    var score: Float = 0.0
    
    /// A log of the various treasures and enemies encountered in a given run.
    var treasuresFound: Set<GKGridGraphNode> = []
    var enemiesEncountered: Set<GKGridGraphNode> = []
    
    // MARK: Initialization
    
    init(position: int2) {
        // Create a player given the specified start position.
        self.position = position
    }
    
    // MARK: Methods
    
    /// Moves a player to a given space and updates score.
    func move(to: GKGridGraphNode) {
        position = int2(to.gridPosition.x, to.gridPosition.y)
        score = score + PlayerConstants.reward
    }
    
    /// Records treasure found and updates score.
    func foundTreasure(at: GKGridGraphNode, scoreChange: Float) {
        treasuresFound.insert(at)
        score = score + scoreChange
    }
    
    /// Records enemy encountered and updates score.
    func encounteredEnemy(at: GKGridGraphNode, scoreChange: Float) {
        enemiesEncountered.insert(at)
        score = score + scoreChange
    }
}
