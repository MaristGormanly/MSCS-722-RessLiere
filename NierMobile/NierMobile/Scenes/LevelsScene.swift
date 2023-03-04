//
//  LevelsScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/4/23.
//

import SpriteKit

class LevelsScene: SKScene {
    
    var starfield:SKEmitterNode!
    var returnHomeButton:SKSpriteNode!
    var completedLevels = [Bool]()
    var numberOfLevels:Int = 5
    var levelOneButton:SKSpriteNode!

    override func didMove(to view: SKView) {
        
        // Check if completedLevels array is stored in UserDefaults
           if let savedLevels = UserDefaults.standard.array(forKey: "completedLevels") as? [Bool] {
               completedLevels = savedLevels
               print(savedLevels)
           } else {
               // If the completedLevels array is not stored in UserDefaults, initialize it to all false
               completedLevels = [Bool](repeating: false, count: numberOfLevels)
               UserDefaults.standard.set(completedLevels, forKey: "completedLevels")
           }
        
        levelOneButton = SKSpriteNode(imageNamed: "level-one")
        levelOneButton .position = CGPoint(x:self.frame.size.width * 0.8, y: self.frame.height * 0.90)
        levelOneButton .setScale(0.75)
        levelOneButton .zRotation = -1*CGFloat.pi / 2.0
        levelOneButton .name = "levelOneButton"
        addChild(levelOneButton)
        
        //initlize startfield
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //initlize postion for starfield
        //TODO: add later to detect for device for placing start field
        starfield.position = CGPoint(x:frame.maxX, y: frame.height / 2)
        //skip 10 seconds into animation
        starfield.advanceSimulationTime(10)
        //add starfield to screen
        addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
        
        returnHomeButton = SKSpriteNode(imageNamed:"return-home")
        returnHomeButton.position = CGPoint(x:self.frame.size.width * 0.18, y: self.frame.height * 0.08)
        returnHomeButton.setScale(0.75)
        returnHomeButton.zRotation = -1*CGFloat.pi / 2.0
        returnHomeButton.name = "returnHomeButton"
        addChild(returnHomeButton)
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == "returnHomeButton" {
            let gameScene = GameScene(fileNamed: "HomeScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
        else if nodesArray.first?.name == "levelOneButton" {
            let gameScene = GameScene(fileNamed: "LevelOneScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
        
    }
}
