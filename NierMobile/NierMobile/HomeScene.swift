//
//  HomeScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/26/23.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

class HomeScene: SKScene {
    var starfield:SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var highScoreButtonNode:SKSpriteNode!
    

    override func didMove(to view: SKView) {
        
        
        starfield = self.childNode(withName: "starfield") as! SKEmitterNode
        //advances animation so the whole screen has the stars
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName:"newGameButton" ) as! SKSpriteNode
        highScoreButtonNode = self.childNode(withName:"highScoreButton" ) as! SKSpriteNode
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size:self.size)
                self.view?.presentScene(gameScene,transition:transition)
                
            }
        }
    }

}
