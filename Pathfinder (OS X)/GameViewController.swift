/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    An `NSViewController` subclass that stores references to game-wide input sources and managers.
*/

import SpriteKit

class GameViewController: NSViewController {
    // MARK: Properties
    
    let scene = GameScene(fileNamed: "GameScene")!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        // Set the scale mode to scale to fit the window.
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene)
        
        // Present entire game scene to QLearning to train and present.
        let ql = QLearning(game: scene)
        ql.learn(episodes: 2500, view: skView)
        
        // SpriteKit applies additional optimizations to improve rendering performance.
        skView.ignoresSiblingOrder = true
    }
}
