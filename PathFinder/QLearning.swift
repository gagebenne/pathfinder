//
//  QLearning.swift
//  Pathfinder
//
//  Created by Gage Benne on 5/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import GameplayKit

extension Array {
    var powerSet: [[Element]] {
        guard !isEmpty else { return [[]] }
        return Array(self[1...]).powerSet.flatMap { [$0, [self[0]] + $0] }
    }
}

class QLearning {
    
    var alpha: Float = 0.1
    var gamma: Float = 0.9
    var epsilon: Float = 0.5
    
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
        var node: GKGridGraphNode
        var treasures: Set<GKGridGraphNode>
        var enemies: Set<GKGridGraphNode>
    }

    var qTable: Dictionary<State, Dictionary<Direction, Float>> = [:]

    init(game: GameScene) {
        
        self.game = game
        node = game.getPlayerPositionNode()
        nextNode = node
        
        let mazeTreasuresPowerSet = Array(game.maze.treasureNodes.keys).powerSet
        let mazeEnemiesPowerSet = Array(game.maze.enemyNodes.keys).powerSet
        var state: State
        
        var i = 0
        var count = game.maze.nodes.count
        
        for n in game.maze.nodes {
            print("\(i) out of \(count)")
            for t in mazeTreasuresPowerSet {
                for e in mazeEnemiesPowerSet {
                    state = State(node: n, treasures: Set(t), enemies: Set(e))
//                    print("node: \(state.node), treasures: \(state.treasures), enemies: \(state.enemies)")
                    qTable.updateValue(Dictionary.init(), forKey: state)
                    for d in Direction.allCases {
                        if game.move(fromNode: state.node, direction: d) != nil {
                            qTable[state]!.updateValue(0.0, forKey: d)
                        }
                    }
                }
            }
            i += 1
        }
    }
    
    func learn(episodes: Int, view: SKView) {
        for e in 1...episodes {
            print("Episode: \(e)")
            game.repeatMaze()
            node = game.getPlayerPositionNode()
            var state = State(node: node, treasures: [], enemies: [])
            
            while !game.gameOver() {
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
//                print("[STATE] node: \(nextState.node), treasures: \(nextState.treasures), enemies: \(nextState.enemies)")
                nextMaxValue = qTable[nextState]!.max { a, b in a.value < b.value }!.value
//                newValue =  oldValue + alpha * (reward + gamma * nextMaxValue - oldValue)
                newValue = (1 - alpha) * oldValue + alpha * (reward + gamma * nextMaxValue)
                qTable[state]![action]! = newValue
                
                state = nextState
            }
            
        }
        
//        prettyPrintQTable()
        animateLearnedPath()
    }
    
    func prettyPrintQTable() {
        print("=============================== Q-TABLE ===============================")
        for (state, v) in qTable {
            print("\(state.node.gridPosition)")
            print("treasures: \(state.treasures), enemies: \(state.enemies)")
            for (dir, val) in v {
                print("\t\(dir): \(val)")
            }
            print("\n")
        }
    }
    
    func learnedPath() -> [GKGridGraphNode]{
        var path: [GKGridGraphNode] = []
        game.repeatMaze()
        let startNode = game.getPlayerPositionNode()
        let endNode = game.maze.endNode
        var state = State(node: startNode, treasures: [], enemies: [])
        
        var i = 0
        print("============================== EXECUTING ==============================")
        while state.node != endNode && i < 1000 {
            path.append(state.node)
//            print("\(state.node.gridPosition)")
//            print("treasures: \(state.treasures), enemies: \(state.enemies)")
//            for (dir, val) in qTable[state]! {
//                print("\t\(dir): \(val)")
//            }
//            print("\n")
            let dir = qTable[state]!.max { a, b in a.value < b.value }!.key
//            print("DIRECTION: \(dir)")
            game.attemptPlayerMove(direction: dir)!
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
