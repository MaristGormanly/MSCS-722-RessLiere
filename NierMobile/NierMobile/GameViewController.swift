//
//  GameViewController.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/23/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let view = self.view as? SKView {
                view.showsNodeCount = false
                view.showsPhysics = false
                view.showsFPS = false
            }

            if let scene = SKScene(fileNamed: "HomeScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
           
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            
        }
    }
    //sets what modes are supported in terms of phone direction
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
