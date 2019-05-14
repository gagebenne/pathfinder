//
//  QLearning.swift
//  Pathfinder
//
//  Created by Gage Benne on 5/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit

class QLearning {
    
    var alpha: Float = 0.5
    var gamma: Float = 0.5
    var epsilon: Float = 0.5
    
    var game: GameScene
    
    struct stateAction: Hashable {
        var node: GKGraphNode
        var direction: Direction
    }

    var qTable: [stateAction: Int] = [:]

    init(game: GameScene) {
        self.game = game
    }
    
    func learn(episodes: Int) {
        
    }
}
