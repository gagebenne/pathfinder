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
    
    var node: GKGridGraphNode
    var action: Direction = Direction(rawValue: 0)!
    var reward: Float = 0.0
    
    var oldValue: Float = 0.0
    var nextMaxValue: Float = 0.0
    var newValue: Float = 0.0
    
    var dirPairs: [(Direction, Float)] = []
    
    var game: GameScene
    
    struct stateAction: Hashable {
        var node: GKGraphNode
        var direction: Direction
    }

//    var qTable: [stateAction: Int] = [:]
    var qTable: Dictionary<GKGridGraphNode, Dictionary<Direction, Float>> = [:]

    init(game: GameScene) {
        self.game = game
        node = game.getPlayerPositionNode()
        
        for d in Direction.allCases {
            dirPairs.append( ( d, Float.random(in: 0.0...10.0) ) )
        }
        
        for n in game.maze.nodes {
            qTable.updateValue(Dictionary.init(uniqueKeysWithValues: dirPairs), forKey: n)
        }
    }
    
    func learn(episodes: Int, view: SKView) {
        for e in 1...episodes {
            print("Episode: \(e)")
            game.repeatMaze()
            node = game.getPlayerPositionNode()
            
            while !game.gameOver() {
                if Float.random(in: 0.0...1.0) < epsilon {
                    action = Direction.randomDirection()
                } else {
                    action = qTable[node]!.max { a, b in a.value < b.value }!.key
                }
                
                game.removePlayer()
                if let r = game.attemptPlayerMove(direction: action) {
                    reward = r
                } else {
                    continue
                }
                game.writePlayer()
                
                oldValue = qTable[node]![action]!
                nextMaxValue = qTable[node]!.max { a, b in a.value < b.value }!.value
                newValue = (1 - alpha) * oldValue + alpha * (reward + gamma * nextMaxValue)
                qTable[node]![action]! = newValue
                
                node = game.getPlayerPositionNode()
            }
        }
        
        prettyPrintQTable()
    }
    
    func prettyPrintQTable() {
        for (node, v) in qTable {
            print("\(node.gridPosition)")
            for (dir, val) in v {
                print("\t\(dir): \(val)")
            }
            print("\n")
        }
    }
}
