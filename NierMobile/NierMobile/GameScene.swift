//
//  GameScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/23/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // ! is optional meaning value does not have be defined right away
    var player:SKSpriteNode!
    var starfield:SKEmitterNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        //initlize startfield
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //initlize postion for starfield
        //TODO: add later to detect for device for placing start field
        starfield.position = CGPoint(x:view.frame.maxX, y: self.frame.height + 100)
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
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        
        //add player to screen
        self.addChild(player)
        
        //set physics for scene zero gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //sets physics rules for contact
        //TODO: contact delegate will be defined
        self.physicsWorld.contactDelegate = self
        
        
        //set the score label inital
        scoreLabel = SKLabelNode(text: "Score - 0")
        //TODO: add as ratio of screen rather than hard coded
        scoreLabel.position = CGPoint(x:self.frame.width / 2, y: self.frame.height - 100)
        print(view.frame.maxY)
        print(self.frame.size.height - 50)
       print(-1*player.size.height/2 - 500)
        //http://iosfonts.com/
        scoreLabel.fontName = "Avenir-BlackOblique"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        
        
       
    }
    
    
 
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
