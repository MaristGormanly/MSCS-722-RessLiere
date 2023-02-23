//
//  GameScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/23/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player:SKSpriteNode!
    var starfield:SKEmitterNode!
    
    
    override func didMove(to view: SKView) {
        //initlize startfield
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //initlize postion for starfield
        //add later to detect for device
        starfield.position = CGPoint(x:0, y: 1472)
        //skip 10 seconds into animation
        starfield.advanceSimulationTime(10)
        //add starfield to screen
        self.addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
        
        
        
        
       
    }
    
    
 
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
