//
//  QLearning.swift
//  Pathfinder
//
//  Created by Gage Benne on 5/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit

struct QLearningConstants {
    static let alpha: Float = 0.3
    static let gamma: Float = 0.9
    static let epsilon: Float = 0.4 
}

class QLearning {
    // MARK: Properties
    
    /**
        Hyperparameters for learning rate (alpha), discount factor (gamma),
        and a sort of exploration factor (epsilon).
    */
    var alpha: Float = QLearningConstants.alpha
    var gamma: Float = QLearningConstants.gamma
    var epsilon: Float = QLearningConstants.epsilon
    
    var node: GKGridGraphNode
    var nextNode: GKGridGraphNode
    var action: Direction = Direction(rawValue: 0)!
    var reward: Float = 0.0
    
    var oldValue: Float = 0.0
    var nextMaxValue: Float = 0.0
    var newValue: Float = 0.0
    
    var game: GameScene
    
    /**
        A state is what we know about the maze environment at any given
        point in exploration, and consists of what node the player is at,
        as well as the treasures and enemies found at that point.
    */
    struct State: Hashable {
        var node: GKGridGraphNode
        var treasures: Set<GKGridGraphNode>
        var enemies: Set<GKGridGraphNode>
    }
    
    /**
        The core of the learning, the qTable which given state and a direction,
        will product a dictionary of directions and their predicted returns
    */
    var qTable: Dictionary<State, Dictionary<Direction, Float>> = [:]
    
    // MARK: Initialization
    
    init(game: GameScene) {
        self.game = game
        node = game.getPlayerPositionNode()
        nextNode = node
    }
    
    func learn(episodes: Int, view: SKView) {
        for e in 1...episodes {
            print("Episode: \(e)")
            game.repeatMaze()
            node = game.getPlayerPositionNode()
            var state = State(node: node, treasures: [], enemies: [])
            
            while !game.gameOver() {
                if qTable[state] == nil {
                    qTable.updateValue(Dictionary.init(), forKey: state)
                        for d in Direction.allCases {
                            if game.move(fromNode: state.node, direction: d) != nil {
                                qTable[state]!.updateValue(0.0, forKey: d)
                            }
                        }
                }
                
                if GKRandomSource.sharedRandom().nextUniform() < epsilon {
                    action = qTable[state]!.keys.randomElement()!
                } else {
                    action = qTable[state]!.max { a, b in a.value < b.value }!.key
                }
                
                if let r = game.attemptPlayerMove(direction: action) {
                    reward = r
                } else {
                    continue
                }
                
                oldValue = qTable[state]![action]!
                nextNode = game.getPlayerPositionNode()
                let nextState = State(node: nextNode, treasures: game.player.treasuresFound, enemies: game.player.enemiesEncountered)
                if qTable[nextState] == nil {
                    qTable.updateValue(Dictionary.init(), forKey: nextState)
                    for d in Direction.allCases {
                        if game.move(fromNode: nextState.node, direction: d) != nil {
                            qTable[nextState]!.updateValue(0.0, forKey: d)
                        }
                    }
                }
                nextMaxValue = qTable[nextState]!.max { a, b in a.value < b.value }!.value
                newValue =  oldValue + alpha * (reward + gamma * nextMaxValue - oldValue)
                qTable[state]![action]! = newValue
                
                state = nextState
            }
            
        }
        animateLearnedPath()
    }
    
    func learnedPath() -> [GKGridGraphNode]{
        var path: [GKGridGraphNode] = []
        game.repeatMaze()
        
        let startNode = game.getPlayerPositionNode()
        let endNode = game.maze.endNode
        
        var state = State(node: startNode, treasures: [], enemies: [])
        
        var i = 0
        
        while state.node != endNode && i < 1000 {
            path.append(state.node)
            let dir = qTable[state]!.max { a, b in a.value < b.value }!.key
            _ = game.attemptPlayerMove(direction: dir)!
            state.node = game.getPlayerPositionNode()
            state.treasures = game.player.treasuresFound
            state.enemies = game.player.enemiesEncountered
            i += 1
        }
        
        path.append(endNode)
        return path
    }
    
    func animateLearnedPath() {
        game.animateSolution(learnedPath())
    }
}
