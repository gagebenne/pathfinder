/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    An `SKScene` subclass that handles logic and visuals.
*/

import SpriteKit
import GameplayKit

enum Direction: Int, CaseIterable {
    case up = 2
    case down = 1
    case left = 0
    case right = 3
    
    static func randomDirection() -> Direction {
        // pick and return a new value
        let rand = Int.random(in: 0...3)
        return Direction(rawValue: rand)!
    }
}

class GameScene: SKScene {
    // MARK: Properties
    
    /// Holds information about the maze.
    var maze: Maze = Maze()
    var player: Player = Player()
    
    /**
        Contains optional sprite nodes that are used to visualize the maze 
        graph. The nodes are arranged in a 2D array (an array with rows and 
        columns) so that the array index of a sprite node in this array 
        corresponds to the coordinates of the node in the maze graph. A node at 
        an index exists if the corresponding maze node exists; otherwise, the 
        sprite node is nil.
    */
    @nonobjc var spriteNodes = [[SKSpriteNode?]]()
    @nonobjc var score = SKLabelNode()
    @nonobjc var alert = SKLabelNode()
    
    // MARK: Methods
    
    /**
        Creates a maze object, and creates a visual representation of that maze
        using sprites.
    */
    func createMaze() {
        print("NEW MAZE")
        maze = Maze()
        generateMazeNodes()
        createPlayer()
    }
    
//      DOESNT WORK
//    func instantReplay() {
//        for n in player.pathTraversed {
//            removePlayer()
//            player.move(to: n)
//            writePlayer()
//        }
//    }
    
    func repeatMaze() {
        print("REPEAT MAZE")
        maze.rebuild()
        generateMazeNodes()
        createPlayer()
    }
    
    func createPlayer() {
        //print("NEW PLAYER")
        player = Player(position: int2(maze.startNode.gridPosition.x, maze.startNode.gridPosition.y))
        writePlayer()
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
        
        //print("\(maze.treasureNodes.count)")
        for treasure in maze.treasureNodes {
            let x = Int(treasure.gridPosition.x)
            let y = Int(treasure.gridPosition.y)
            spriteNodes[x][y]?.color = SKColor.yellow
        }
        
        for enemy in maze.enemyNodes {
            let x = Int(enemy.gridPosition.x)
            let y = Int(enemy.gridPosition.y)
            spriteNodes[x][y]?.color = SKColor.orange
        }
        
        score.text = "Score: 0"
        score.position = CGPoint(x: mazeParentNode.size.width/2, y: -cellDimension)
        mazeParentNode.addChild(score)
    }
    
    /// Animates a solution to the maze.
    func animateSolution(_ solution: [GKGridGraphNode]) {
        /*
            The animation works by animating sprites with different start delays.
            actionDelay represents this delay, which increases by
            an interval of actionInterval with each iteration of the loop.
        */
        var actionDelay: TimeInterval = 0
        let actionInterval = 0.005
        
        /*
            Light up each sprite in the solution sequence, except for the
            start and end nodes.
        */
        for i in 1...(solution.count - 2) {
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
    
    func removePlayer() {
        let playerX = Int(player.position.x)
        let playerY = Int(player.position.y)
        spriteNodes[playerX][playerY]?.color = SKColor.darkGray
    }
    
    func writePlayer() {
        let playerX = Int(player.position.x)
        let playerY = Int(player.position.y)
        spriteNodes[playerX][playerY]?.color = SKColor.white
    }
    
    func attemptPlayerMove(direction: Direction) -> Float? {
        if gameOver() {
            print("GAME OVER")
            return nil
        }
        let playerX = Int32(player.position.x)
        let playerY = Int32(player.position.y)
        var attemptPos: GKGridGraphNode?
        
        switch direction {
            case .up:
                attemptPos = maze.graph.node(atGridPosition: int2(playerX, playerY+1))
            case .down:
                attemptPos = maze.graph.node(atGridPosition: int2(playerX, playerY-1))
            case .left:
                attemptPos = maze.graph.node(atGridPosition: int2(playerX-1, playerY))
            case .right:
                attemptPos = maze.graph.node(atGridPosition: int2(playerX+1, playerY))
        }
        
        // check to see if move is valid then move player
        if let newPos = attemptPos {
            removePlayer()
            player.move(to: newPos)
            if maze.treasureNodes.contains(newPos) {
                player.foundTreasure(at: newPos)
                maze.treasureNodes.removeAll{$0 == newPos}
            }
            if maze.enemyNodes.contains(newPos) {
                player.encounteredEnemy(at: newPos)
                maze.enemyNodes.removeAll{$0 == newPos}
            }
            let scoreDelta = player.updateScore()
            //print("Score: \(String(player.score))")
            writePlayer()
            
            return scoreDelta
        } else {
            //print("NOT ALLOWED")
        }
        return nil
    }
    
    func gameOver() -> Bool {
        return maze.graph.node(atGridPosition: player.position) == maze.endNode
    }
    
    func getPlayerPositionNode() -> GKGridGraphNode {
        return maze.graph.node(atGridPosition: player.position)!
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
                attemptPlayerMove(direction: .left)
            case 124: // right
                attemptPlayerMove(direction: .right)
            case 125: // down
                attemptPlayerMove(direction: .down)
            case 126: // up
                attemptPlayerMove(direction: .up)
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
