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
    var levelTwoButton:SKSpriteNode!
    var titleLabel:SKLabelNode!
    var levelLock: SKSpriteNode!

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
        let titleColor = UIColor(red: 0.79, green: 0.85, blue: 0.32, alpha: 1.0)
        
        titleLabel = SKLabelNode(text: "Levels: ")
        titleLabel.zRotation = -1*CGFloat.pi / 2.0
        
        titleLabel.position = CGPoint(x:self.frame.width * 0.80 , y: self.frame.height / 2)
        
        titleLabel.fontName = "Copperplate"
        titleLabel.fontSize = 72
        titleLabel.fontColor = titleColor
        addChild(titleLabel)
        
        
        
        
      
        
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
        
        
        
        initLevelOne()
        if(completedLevels[0]){
            initLevelTwo()
        }
        else{
            initLockedLevel(pos:CGPoint(x:self.frame.size.width * 0.65, y: self.frame.height * 0.7))

        }
       
        
        
       
    }
    
    func initLevelOne(){
        levelOneButton = SKSpriteNode(imageNamed: "level-one")
        levelOneButton .position = CGPoint(x:self.frame.size.width * 0.65, y: self.frame.height * 0.85)
        levelOneButton .setScale(1.4)
        levelOneButton .zRotation = -1*CGFloat.pi / 2.0
        levelOneButton .name = "levelOneButton"
        addChild(levelOneButton)
        
    }
    
    func initLevelTwo(){
        levelTwoButton = SKSpriteNode(imageNamed: "level-two")
        levelTwoButton .position = CGPoint(x:self.frame.size.width * 0.65, y: self.frame.height * 0.7)
        levelTwoButton .setScale(1.4)
        levelTwoButton .zRotation = -1*CGFloat.pi / 2.0
        levelTwoButton .name = "levelTwoButton"
        addChild(levelTwoButton)
        
    }
    func initLockedLevel(pos:CGPoint){
        levelLock = SKSpriteNode(imageNamed: "locked-level")
        levelLock.position = pos
        levelLock.zRotation = -1*CGFloat.pi / 2.0
        levelLock.setScale(1.3)
        levelLock.name = "levelLock"
        addChild(levelLock)

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
