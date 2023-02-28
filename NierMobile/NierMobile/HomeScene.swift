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
    
    var newGameButtonNode:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == "newGameButton" {
            let gameScene = GameScene(fileNamed: "GameScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
            
            
        }
    }
}


