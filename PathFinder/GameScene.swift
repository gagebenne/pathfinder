/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    An `SKScene` subclass that handles logic and visuals.
*/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: Types
    
    /// An enum for the cardinal directions.
    enum Direction: Int, CaseIterable {
        case left = 0, down, right, up
    }
    
    
    // MARK: Properties
    
    /// Holds information about the maze.
    var maze: Maze = Maze()
    
    /// Holds information about the player.
    var player: Player = Player(position: int2(0,0))
    
    /**
        Contains optional sprite nodes that are used to visualize the maze 
        graph. The nodes are arranged in a 2D array (an array with rows and 
        columns) so that the array index of a sprite node in this array 
        corresponds to the coordinates of the node in the maze graph. A node at 
        an index exists if the corresponding maze node exists; otherwise, the 
        sprite node is nil.
    */
    @nonobjc var spriteNodes = [[SKSpriteNode?]]()
    
    // MARK: Methods
    
    /**
        Creates a maze object, creates a visual representation of that maze
        using sprites, and initializes a new player.
    */
    func createMaze() {
        maze = Maze()
        generateMazeNodes()
        createPlayer()
    }
    
    /**
        Rebuilds the current maze object by restoring treasures and enemies;
        still creates a visual representation of that maze using sprites,
        along with a new player.
     */
    func repeatMaze() {
        maze.rebuild()
        generateMazeNodes()
        createPlayer()
    }
    
    /// Creates a new player at the maze's start position.
    func createPlayer() {
        player = Player(position: int2(maze.startNode.gridPosition.x, maze.startNode.gridPosition.y))
        writePlayer()
    }
    
    /// Colors sprite node dark gray to infer leaving that space when animating.
    func removePlayer() {
        let playerX = Int(player.position.x)
        let playerY = Int(player.position.y)
        spriteNodes[playerX][playerY]?.color = SKColor.darkGray
    }
    
    /// Colors sprite node white to infer arriving at that space when animating.
    func writePlayer() {
        let playerX = Int(player.position.x)
        let playerY = Int(player.position.y)
        spriteNodes[playerX][playerY]?.color = SKColor.white
    }
    
    /**
        The core movement method, attempts to move player in a given direction
        by first checking to see if the game is over 
     */
    func attemptPlayerMove(direction: Direction) -> Float? {
        // Disallow movement if the game is over.
        if gameOver() {
            return nil
        }
        let playerNode = maze.graph.node(atGridPosition: player.position)!
        
        // Move the player after checking to see if the move is indeed valid.
        if let newNode = move(fromNode: playerNode, direction: direction) {
            let pastScore = player.score
            
            player.move(to: newNode)
            if let treasureVal = maze.treasureNodes[newNode] {
                player.foundTreasure(at: newNode, scoreChange: treasureVal)
                maze.treasureNodes.removeValue(forKey: newNode)
            }
            if let enemyVal = maze.enemyNodes[newNode] {
                player.encounteredEnemy(at: newNode, scoreChange: enemyVal)
                maze.enemyNodes.removeValue(forKey: newNode)
                //                print("\tENEMY FOUND AT: \(newNode.gridPosition)")
            }
            if gameOver() {
                //                print("\t+ -------- + ")
                //                print("\t| WON GAME | ")
                //                print("\t+ -------- + ")
                player.score += 1000
            }
            //print("Score: \(String(player.score))")
            
            return player.score - pastScore
        } else {
            //print("NOT ALLOWED")
            return nil
        }
    }
    
    func move(fromPos: int2, direction: Direction) -> int2? {
        let node = maze.graph.node(atGridPosition: fromPos)!
        
        if let newNode = move(fromNode: node, direction: direction) {
            return newNode.gridPosition
        } else {
            return nil
        }
    }
    
    func move(fromNode: GKGridGraphNode, direction: Direction) -> GKGridGraphNode? {
        let x = fromNode.gridPosition.x
        let y = fromNode.gridPosition.y
        
        switch direction {
        case .up:
            return maze.graph.node(atGridPosition: int2(x, y+1))
        case .down:
            return maze.graph.node(atGridPosition: int2(x, y-1))
        case .left:
            return maze.graph.node(atGridPosition: int2(x-1, y))
        case .right:
            return maze.graph.node(atGridPosition: int2(x+1, y))
        }
    }
    
    func gameOver() -> Bool {
        return player.position == maze.endNode.gridPosition
    }
    
    func getPlayerPositionNode() -> GKGridGraphNode {
        return maze.graph.node(atGridPosition: player.position)!
    }

    // MARK: SpriteKit Methods
    
    /// Generates a maze when the game starts.
    override func didMove(to _: SKView) {
        createMaze()
    }
    
    /// Generates sprite nodes that comprise the maze's visual representation.
    func generateMazeNodes() {
        // Initialize the an array of sprites for the maze.
        spriteNodes += [[SKSpriteNode?]](repeating: [SKSpriteNode?](repeating: nil, count: (Maze.dimensions * 2) - 1), count: Maze.dimensions
        )
        
        /*
            Grab the maze's parent node from the scene and use it to
            calculate the size of the maze's cell sprites.
        */
        let mazeParentNode = childNode(withName: "maze") as! SKSpriteNode
        let cellDimension = mazeParentNode.size.height / CGFloat(Maze.dimensions)
        
        // Remove existing maze cell sprites from the previous maze.
        mazeParentNode.removeAllChildren()
        
        // For each maze node in the maze graph, create a corresponding sprite.
        let graphNodes = maze.graph.nodes as? [GKGridGraphNode]
        for node in graphNodes! {
            // Get the position of the maze node.
            let x = Int(node.gridPosition.x)
            let y = Int(node.gridPosition.y)
            
            /*
                Create a maze sprite node and place the sprite at the correct 
                location relative to the maze's parent node.
            */
            let mazeNode = SKSpriteNode(
                color: SKColor.darkGray,
                size: CGSize(width: cellDimension, height: cellDimension)
            )
            mazeNode.anchorPoint = CGPoint(x: 0, y: 0)
            mazeNode.position = CGPoint(x: CGFloat(x) * cellDimension, y: CGFloat(y) * cellDimension)
            
            // Add the maze sprite node to the maze's parent node.
            mazeParentNode.addChild(mazeNode)
            
            /*
                Add the maze sprite node to the 2D array of sprite nodes so we 
                can reference it later.
            */
            spriteNodes[x][y] = mazeNode
        }
        
        // Grab the coordinates of the start and end maze sprite nodes.
        let startNodeX = Int(maze.startNode.gridPosition.x)
        let startNodeY = Int(maze.startNode.gridPosition.y)
        let endNodeX   = Int(maze.endNode.gridPosition.x)
        let endNodeY   = Int(maze.endNode.gridPosition.y)
        
        // Color the start and end nodes green and red, respectively.
        spriteNodes[startNodeX][startNodeY]?.color = SKColor.green
        spriteNodes[endNodeX][endNodeY]?.color     = SKColor.red
        
        // Color the treasure nodes yellow.
        for (treasure, _) in maze.treasureNodes {
            let x = Int(treasure.gridPosition.x)
            let y = Int(treasure.gridPosition.y)
            spriteNodes[x][y]?.color = SKColor.yellow
        }
        
        // Color the treasure nodes orange.
        for (enemy, _) in maze.enemyNodes {
            let x = Int(enemy.gridPosition.x)
            let y = Int(enemy.gridPosition.y)
            spriteNodes[x][y]?.color = SKColor.orange
        }
    }
    
    /// Animates a solution to the maze.
    func animateSolution(_ solution: [GKGridGraphNode]) {
        repeatMaze()
        /*
            The animation works by animating sprites with different start delays.
            actionDelay represents this delay, which increases by
            an interval of actionInterval with each iteration of the loop.
        */
        var actionDelay: TimeInterval = 0
        let actionInterval = 0.1
        
        /*
            Light up each sprite in the solution sequence, except for the
            start and end nodes.
        */
        for i in 0...(solution.count - 2) {
            // Grab the position of the maze graph node.
            let x = Int(solution[i].gridPosition.x)
            let y = Int(solution[i].gridPosition.y)
            
            /*
                Increment the action delay so this sprite is highlighted
                after the previous one.
            */
            actionDelay += actionInterval
            
            // Run the animation action on the maze sprite node.
            if let mazeNode = spriteNodes[x][y] {
                // FIXME: This needs to be better somehow.
                let nodeXY = maze.graph.node(atGridPosition: int2(Int32(x), Int32(y)))
                if maze.treasureNodes[nodeXY!] != nil {
                    mazeNode.run(
                        SKAction.sequence(
                            [SKAction.colorize(with: SKColor.yellow, colorBlendFactor: 1, duration: 0.2),
                             SKAction.wait(forDuration: actionDelay),
                             SKAction.colorize(with: SKColor.yellow, colorBlendFactor: 1, duration: 0),
                             SKAction.colorize(with: SKColor.yellow, colorBlendFactor: 1, duration: 0.3)]
                        )
                    )
                } else if maze.enemyNodes[nodeXY!] != nil {
                    mazeNode.run(
                        SKAction.sequence(
                            [SKAction.colorize(with: SKColor.orange, colorBlendFactor: 1, duration: 0.2),
                             SKAction.wait(forDuration: actionDelay),
                             SKAction.colorize(with: SKColor.orange, colorBlendFactor: 1, duration: 0),
                             SKAction.colorize(with: SKColor.orange, colorBlendFactor: 1, duration: 0.3)]
                        )
                    )
                } else {
                    mazeNode.run(
                        SKAction.sequence(
                            [SKAction.colorize(with: SKColor.gray, colorBlendFactor: 1, duration: 0.2),
                             SKAction.wait(forDuration: actionDelay),
                             SKAction.colorize(with: SKColor.white, colorBlendFactor: 1, duration: 0),
                             SKAction.colorize(with: SKColor.lightGray, colorBlendFactor: 1, duration: 0.3)]
                        )
                    )
                }
            }
        }
    }
}

// MARK: OS X Input Handling

#if os(OSX)
    extension GameScene {
        /**
            Advances the game by creating a new maze or solving the existing maze if
            a key press is detected.
        */
        override func keyDown(with keyPress: NSEvent) {
            switch keyPress.keyCode {
            case 123: // left
                removePlayer()
                attemptPlayerMove(direction: .left)
                writePlayer()
            case 124: // right
                removePlayer()
                attemptPlayerMove(direction: .right)
                writePlayer()
            case 125: // down
                removePlayer()
                attemptPlayerMove(direction: .down)
                writePlayer()
            case 126: // up
                removePlayer()
                attemptPlayerMove(direction: .up)
                writePlayer()
            case 36:
                repeatMaze()
            default:
                print("Key with number: \(keyPress.keyCode) was pressed")
            }
        }
        
        /**
            Advances the game by creating a new maze or solving the existing maze if
            a click is detected.
        */
        override func mouseDown(with _: NSEvent) {
            createMaze()
        }
    }
#endif
