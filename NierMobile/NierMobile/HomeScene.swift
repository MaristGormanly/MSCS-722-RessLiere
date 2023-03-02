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
    var settingButtonNode:SKSpriteNode!
    var storyModeButtonNode:SKSpriteNode!
    
    override func didMove(to view: SKView) {
       newGameButtonNode = SKSpriteNode(imageNamed: "start-button")
        newGameButtonNode.position = CGPoint(x:self.frame.size.width * 0.55, y: self.frame.height / 2)
        newGameButtonNode.zRotation =  -1*CGFloat.pi / 2.0
        newGameButtonNode.name =  "newGameButton"
        addChild(newGameButtonNode)
        
        settingButtonNode = SKSpriteNode(imageNamed: "setting-button")
        settingButtonNode.setScale(0.5)
        settingButtonNode.position = CGPoint(x:self.frame.size.width * 0.18, y: self.frame.height * 0.08)
        settingButtonNode.zRotation = -1*CGFloat.pi / 2.0
        settingButtonNode.name = "settingButton"
        addChild(settingButtonNode)
        
        storyModeButtonNode = SKSpriteNode(imageNamed: "story-button")
        storyModeButtonNode.position = CGPoint(x:self.frame.size.width * 0.30, y: self.frame.height / 2)
        storyModeButtonNode.zRotation =  -1*CGFloat.pi / 2.0
        storyModeButtonNode.name =  "storyButton"
        addChild(storyModeButtonNode)

        
        
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
        else if nodesArray.first?.name == "storyButton"{
            let gameScene = GameScene(fileNamed: "LevelOneScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
            
        }
        else if nodesArray.first?.name == "settingButton"{
          
            UserDefaults.standard.removeObject(forKey: "highestScore")
        }
    }
}


