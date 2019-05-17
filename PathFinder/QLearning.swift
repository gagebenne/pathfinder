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
    
    var alpha: Float = 0.9
    var gamma: Float = 0.9
    var epsilon: Float = 0.5
    
    var node: GKGridGraphNode
    var nextNode: GKGridGraphNode
    var action: Direction = Direction(rawValue: 0)!
    var reward: Float = 0.0
    

    
    var dirPairs: [(Direction, Float)] = []
    
    var game: GameScene
    
    struct State: Hashable {
        var node: GKGridGraphNode?
    }
    
    struct Value {
        var exit: Bool = false
        var treasureVal: Float = 0.0
        var enemyVal: Float = 0.0
        
        func getValue() -> Float {
            if exit {
                return treasureVal + enemyVal
            } else {
                return treasureVal + enemyVal - 1000
            }
        }
    }

//    var qTable: Dictionary<State, Dictionary<Direction, Float>> = [:]
    var qTable: Dictionary<State, Dictionary<Direction, Value>> = [:]



    init(game: GameScene) {
        self.game = game
        node = game.getPlayerPositionNode()
        nextNode = node
        
        var state: State = State()

        for n in game.maze.nodes {
            state.node = n
            
            qTable.updateValue(Dictionary.init(), forKey: state)
            for d in Direction.allCases {
                if game.move(fromNode: n, direction: d) != nil {
                    qTable[state]!.updateValue(Value(), forKey: d)
                }
            }
        }
        let endState = State(node: game.maze.endNode)
        for dir in qTable[endState]!.keys {
            qTable[endState]![dir]!.exit = true
        }
    }
    
    func learn(episodes: Int, view: SKView) {
        var state: State = State()
        var nextState: State = State()
        
        var currentTreasureValue: Float = 0.0
        var currentEnemyValue: Float = 0.0
        var currentHasExit: Bool = false
        var nextTreasureMaxValue: Float = 0.0
        var nextEnemyMaxValue: Float = 0.0
        var nextHasExit: Bool = false
        var newTreasureValue: Float = 0.0
        var newEnemyValue: Float = 0.0
        var newHasExit: Bool = false


        for e in 1...episodes {
            print("Episode: \(e)")
            game.repeatMaze()
            node = game.getPlayerPositionNode()
            state.node = node
            
            while !game.gameOver() {
                if GKRandomSource.sharedRandom().nextUniform() < epsilon {
                    action = qTable[state]!.keys.randomElement()!
                } else {
                    action = qTable[state]!.max { a, b in a.value.getValue() < b.value.getValue() }!.key
                }
                
                reward = game.attemptPlayerMove(direction: action)!
                
                nextNode = game.move(fromNode: node, direction: action)!
                nextState.node = nextNode
                
                currentHasExit = qTable[state]![action]!.exit
                nextHasExit = !(qTable[nextState]!.filter { a in a.value.exit }.isEmpty)
                newHasExit = nextHasExit
                qTable[state]![action]!.exit = newHasExit
                
                currentTreasureValue = qTable[state]![action]!.treasureVal
                nextTreasureMaxValue = qTable[nextState]!.max { a, b in a.value.treasureVal < b.value.treasureVal }!.value.treasureVal
                newTreasureValue = (1 - alpha) * currentTreasureValue + alpha * (reward + gamma * nextTreasureMaxValue)
                qTable[state]![action]!.treasureVal = newTreasureValue
                
                currentEnemyValue = qTable[state]![action]!.enemyVal
                nextEnemyMaxValue = qTable[nextState]!.max { a, b in a.value.enemyVal < b.value.enemyVal }!.value.enemyVal
                newEnemyValue = (1 - alpha) * currentEnemyValue + alpha * (reward + gamma * nextEnemyMaxValue)
                qTable[state]![action]!.enemyVal = newEnemyValue

                node = nextNode
                state.node = node
            }
            // EVENTUALLY REMOVE??
//            qTable[state]!.updateValue(1000000.0, forKey: .up)
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
        
        game.repeatMaze()
        
        var i = 0
        while currentNode != endNode && i < 1000 {
            currentState.node = currentNode
            
            path.append(currentNode)
            print(currentNode.gridPosition)
            let dir = (qTable[currentState]!
                .filter { a in a.value.exit }
                .max { a, b in a.value.getValue() < b.value.getValue() })!.key
//          qTable[currentState]!.removeValue(forKey: dir)
//          currentNode = game.move(fromNode: currentNode, direction: dir)!
//            print("Moving \(dir) from \(game.player.position)")
            game.attemptPlayerMove(direction: dir)!
            currentNode = game.getPlayerPositionNode()
            
            i += 1
        }
        path.append(endNode)
        
        return path
    }
    
    func animateLearnedPath() {
        game.animateSolution(learnedPath())
    }
}
