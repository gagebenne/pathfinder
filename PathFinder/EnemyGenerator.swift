//
//  Enemy.swift
//  Pathfinder
//
//  Created by Andy Monroe on 5/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit

class EnemyGenerator {
    // MARK: Properties
    
    /// A reference to the maze that the maze builder is building for.
    let maze: Maze
    
    // MARK: Initialization
    
    init(maze: Maze) {
        self.maze = maze
    }
    
    // MARK: Methods
    
    func generateEnemies() -> Dictionary<GKGridGraphNode, Float> {
        let graphNodes = maze.graph.nodes!.filter { node in
            // Randomly filter node into the array.
            return Int.random(in: 1...100) % 20 == 0
            } as! [GKGridGraphNode]
        
        // Filter in the nodes that could potentially be enemies.
        var enemyNodes: Dictionary<GKGridGraphNode, Float> = [:]
        for n in graphNodes {
            enemyNodes.updateValue(-10.0, forKey: n)
        }

        return enemyNodes
    }

}
