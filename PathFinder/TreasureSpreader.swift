//
//  TreasureSpreader.swift
//  Pathfinder
//
//  Created by Gage Benne on 5/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit

struct TreasureSpreaderConstants {
    /// The reward for picking up a treasure.
    static let reward: Float = 20.0
    
    /// Probability (out of 100%) of burying a treasure at a given node.
    static let probability = 10
}

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
            return Int.random(in: 0...99) < TreasureSpreaderConstants.probability
            } as! [GKGridGraphNode]
        
        // Filter in the nodes that could potentially be treasures.
        var treasureNodes: Dictionary<GKGridGraphNode, Float> = [:]
        for n in graphNodes {
            treasureNodes.updateValue(TreasureSpreaderConstants.reward, forKey: n)
        }
        treasureNodes.removeValue(forKey: maze.startNode)
        treasureNodes.removeValue(forKey: maze.endNode)
        
        return treasureNodes
    }
}
