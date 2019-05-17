//
//  TreasureSpreader.swift
//  Pathfinder
//
//  Created by Gage Benne on 5/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit

class TreasureSpreader {
    // MARK: Properties
    
    /// A reference to the maze that the maze builder is building for.
    let maze: Maze
    
    // MARK: Initialization
    
    init(maze: Maze) {
        self.maze = maze
    }
    
    // MARK: Methods
    
    func buryTreasure() -> Dictionary<GKGridGraphNode, Float> {
        let graphNodes = maze.graph.nodes!.filter { node in
            // Randomly filter node into the array.
            return Int.random(in: 1...100) % 10 == 0
            } as! [GKGridGraphNode]
        
        // Filter in the nodes that could potentially be treasures.
        var treasureNodes: Dictionary<GKGridGraphNode, Float> = [:]
        for n in graphNodes {
            treasureNodes.updateValue(200.0, forKey: n)
        }
        treasureNodes.removeValue(forKey: maze.startNode)
        treasureNodes.removeValue(forKey: maze.endNode)
        
        return treasureNodes
    }
}
