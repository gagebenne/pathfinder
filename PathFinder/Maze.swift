/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Handles data for a maze.
*/

import GameplayKit
import SpriteKit

struct MazeConstants {
    static let Dimensions = 19
}

class Maze {
    // MARK: Properties
    
    /**
        Defines the width (and height) of the maze. This is the actual number of rows (and columns) of the maze graph. Since the maze contains walls between traversable areas, these walls must be represented in the navigability graph. 
    
        - Note: This value must be odd.
    */
    static let dimensions = MazeConstants.Dimensions
    
    /// A grid-based graph representing the navigability space of the maze.
    var graph: GKGridGraph<GKGridGraphNode>
    
    /// A node in a grid-based graph representing the starting point of the maze.
    var startNode: GKGridGraphNode
    
    /// A node in a grid-based graph representing the ending point of the maze.
    var endNode: GKGridGraphNode
    
    /// Nodes in a grid-based graph representing the nodes that have treasure.
    var treasureNodes: Dictionary<GKGridGraphNode, Float> = [:]
    
    /// Nodes in a grid-based graph representing the nodes that have enemies.
    var enemyNodes: Dictionary<GKGridGraphNode, Float> = [:]
    
    var nodes: [GKGridGraphNode] = []
    
    /// Nodes in a grid-based graph representing the nodes that have treasure.
    private var mazeTreasureNodes: Dictionary<GKGridGraphNode, Float> = [:]
    
    /// Nodes in a grid-based graph representing the nodes that have enemies.
    private var mazeEnemyNodes: Dictionary<GKGridGraphNode, Float> = [:]
    
    // MARK: Initialization
    
    init() {
        // Initialize the maze graph. At this point, the graph has no walls.
        graph = GKGridGraph(fromGridStartingAt: int2(0, 0), width: Int32(Maze.dimensions), height: Int32(Maze.dimensions), diagonalsAllowed: false)
        
        /* 
            Define the maze's start and end nodes.
            
            - Note: These nodes must have both an even x and an even y 
            coordinate, otherwise they may not remain on the maze graph after 
            the maze walls are removed.
        */
        startNode = graph.node(atGridPosition: int2(0, Int32(Maze.dimensions - 1)))!
        endNode   = graph.node(atGridPosition: int2(Int32(Maze.dimensions - 1), 0))!
        
        /*
            Create a MazeBuilder to generate a random set of walls, then remove 
            them from the maze graph. By removing these nodes, you prevent them 
            from being traversable, so they serve as impassible walls.
        */
        let mazeBuilder = MazeBuilder(maze: self)
        let mazeWalls = mazeBuilder.mazeWallsForRemoval()
        graph.remove(mazeWalls)
        
        for i in 0..<MazeConstants.Dimensions {
            for j in 0..<MazeConstants.Dimensions {
                if let n = graph.node(atGridPosition: int2(Int32(i),Int32(j))) {
                    nodes.append(n)
                }
            }
        }
        
        /*
            Create a TreasureSpreader and EnemyGenerator to generate a random
            set of treasures and enemies.
        */
        treasureNodes = TreasureSpreader(maze: self).buryTreasure()
        mazeTreasureNodes = treasureNodes
        
        enemyNodes = EnemyGenerator(maze: self).generateEnemies()
        mazeEnemyNodes = enemyNodes
    }
    
    // MARK: Methods
    
    /// Rebuilds a maze by restoring treasures and enemies.
    func rebuild() {
        treasureNodes = mazeTreasureNodes
        enemyNodes = mazeEnemyNodes
    }
}
