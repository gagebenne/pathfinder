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
    
    func generateEnemies() -> [GKGridGraphNode] {
        let graphNodes = maze.graph.nodes as! [GKGridGraphNode]
        
        // Filter in the nodes that could potentially be walls.
        let enemyNodes = graphNodes.filter { node in
            
            // Randomly filter node into the array.
            return Int.random(in: 1...100) % 50 == 0
        }
        return enemyNodes
    }
}
