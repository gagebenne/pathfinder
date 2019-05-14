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
    
    var alpha: Float = 0.1
    var gamma: Float = 0.8
    var epsilon: Float = 0.1
    
    var node: GKGridGraphNode
    var nextNode: GKGridGraphNode
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

    var qTable: Dictionary<GKGridGraphNode, Dictionary<Direction, Float>> = [:]

    init(game: GameScene) {
        self.game = game
        node = game.getPlayerPositionNode()
        nextNode = node
        
        for n in game.maze.nodes {
            qTable.updateValue(Dictionary.init(), forKey: n)
            for d in Direction.allCases {
                if game.move(fromNode: n, direction: d) != nil {
                    qTable[n]!.updateValue(Float.random(in: 0.0...1.0), forKey: d)
                }
            }
        }
    }
    
    func learn(episodes: Int, view: SKView) {
        for e in 1...episodes {
            print("Episode: \(e)")
            game.repeatMaze()
            node = game.getPlayerPositionNode()
            
            while !game.gameOver() {
                if GKRandomSource.sharedRandom().nextUniform() < epsilon {
                    action = qTable[node]!.keys.randomElement()!
                } else {
                    action = qTable[node]!.max { a, b in a.value < b.value }!.key
                }
                
                if let r = game.attemptPlayerMove(direction: action) {
                    reward = r
                } else {
                    continue
                }
                
                oldValue = qTable[node]![action]!
                nextNode = game.move(fromNode: node, direction: action)!
                nextMaxValue = qTable[nextNode]!.max { a, b in a.value < b.value }!.value
                newValue = (1 - alpha) * oldValue + alpha * (reward + gamma * nextMaxValue)
                qTable[node]![action]! = newValue
                
                node = nextNode
            }
            // EVENTUALLY REMOVE??
            qTable[node]!.updateValue(100.0, forKey: .up)
        }
        
        prettyPrintQTable()
        animateLearnedPath()
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
    
    func learnedPath() -> [GKGridGraphNode]{
        var path: [GKGridGraphNode] = []
        let startNode = game.maze.startNode
        let endNode = game.maze.endNode
        var currentNode = startNode
        
        var i = 0
        while currentNode != endNode && i < 100 {
            path.append(currentNode)
            let dir = qTable[currentNode]!.max { a, b in a.value < b.value }!.key
            currentNode = game.move(fromNode: currentNode, direction: dir)!
            i += 1
        }
        path.append(endNode)
        
        return path
    }
    
    func animateLearnedPath() {
        game.animateSolution(learnedPath())
    }
}
