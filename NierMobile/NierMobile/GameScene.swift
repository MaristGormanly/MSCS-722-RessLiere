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
        //TODO: add later to detect for device for placing start field
        starfield.position = CGPoint(x:0, y: 1400)
        //skip 10 seconds into animation
        starfield.advanceSimulationTime(10)
        //add starfield to screen
        self.addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
        
        //create a player
        player = SKSpriteNode(imageNamed: "shuttle")
        
        
        let centerX = view.frame.midX
        let centerY = view.frame.midY
        //set player intial postiion
        player.position = CGPoint(x: centerX, y: centerY)
        
        //add player to screen
        self.addChild(player)
        
        
        
        
        
       
    }
    
    
 
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
