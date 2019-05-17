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
    
    struct State: Hashable {
        var node: GKGridGraphNode?
        var visited: Bool = false
    }

    var qTable: Dictionary<State, Dictionary<Direction, Float>> = [:]


    init(game: GameScene) {
        self.game = game
        node = game.getPlayerPositionNode()
        nextNode = node
        
        var state: State = State()

        for n in game.maze.nodes {
            state.node = n
            
            state.visited = true
            qTable.updateValue(Dictionary.init(), forKey: state)
            for d in Direction.allCases {
                if game.move(fromNode: n, direction: d) != nil {
                    qTable[state]!.updateValue(Float.random(in: 0.0...1.0), forKey: d)
                }
            }
            
            state.visited = false
            qTable.updateValue(Dictionary.init(), forKey: state)
            for d in Direction.allCases {
                if game.move(fromNode: n, direction: d) != nil {
                    qTable[state]!.updateValue(Float.random(in: 0.0...1.0), forKey: d)
                }
            }
        }
    }
    
    func learn(episodes: Int, view: SKView) {
        var state: State = State()
        var nextState: State = State()

        
        for e in 1...episodes {
            print("Episode: \(e)")
            game.repeatMaze()
            node = game.getPlayerPositionNode()
            state.node = node
            state.visited = true
            
            while !game.gameOver() {
                if GKRandomSource.sharedRandom().nextUniform() < epsilon {
                    action = qTable[state]!.keys.randomElement()!
                } else {
                    action = qTable[state]!.max { a, b in a.value < b.value }!.key
                }
                
                reward = game.attemptPlayerMove(direction: action)!
                
                nextNode = game.move(fromNode: node, direction: action)!
                nextState.node = nextNode
                nextState.visited = true
                
                oldValue = qTable[state]![action]!
                nextMaxValue = qTable[nextState]!.max { a, b in a.value < b.value }!.value
                newValue = (1 - alpha) * oldValue + alpha * (reward + gamma * nextMaxValue)
                qTable[state]![action]! = newValue

                
                node = nextNode
                state.node = node
            }
            // EVENTUALLY REMOVE??
            qTable[state]!.updateValue(100.0, forKey: .up)
        }
        
        prettyPrintQTable()
        animateLearnedPath()
    }
    
    func prettyPrintQTable() {
        for (state, v) in qTable {
            print("\(state.node!.gridPosition)")
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
        var currentState: State = State()
        var dir: Direction = .up
        var trail: [Direction] = []
//        let qCopy = qTable
        
        var i = 0
        while currentNode != endNode && i < 1000 {
            currentState.node = currentNode
            currentState.visited = true
            
            path.append(currentNode)
            if let dirVal = (qTable[currentState]!.max { a, b in a.value < b.value }) {
                dir = dirVal.key
                qTable[currentState]!.removeValue(forKey: dir)
                currentNode = game.move(fromNode: currentNode, direction: dir)!
                trail.append(Direction.opposite(dir: dir))
            } else {
                dir = trail.popLast()!
                currentNode = game.move(fromNode: currentNode, direction: dir)!
            }
            
            i += 1
        }
        path.append(endNode)
        
        return path
    }
    
    func animateLearnedPath() {
        game.animateSolution(learnedPath())
    }
}
