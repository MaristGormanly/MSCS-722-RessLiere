//
//  LevelZeroScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/5/23.
//

import SpriteKit

class LevelZeroScene: SKScene, SKPhysicsContactDelegate {
    let game = GameInitializer()
    let robotCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let playerCategory: UInt32 = 0x1 << 2
    let worldNode = SKNode()
    var player:SKSpriteNode!
    var levelGoal:Int = 5
    var enemyDeadCount: Int  = 0
    var counterLabel: SKLabelNode!

    
    
    override func didMove(to view: SKView) {
        addChild(worldNode)
        counterLabel = SKLabelNode(text: "Enemies Left: \(levelGoal) ")
             counterLabel.fontSize = 24
             counterLabel.fontName = "Avenir-BlackOblique"
             counterLabel.zRotation =  -1*CGFloat.pi / 2.0
             counterLabel.fontColor = .white
            counterLabel.position = CGPoint(x: self.frame.width * 0.85 , y: self.frame.height / 2)

        //initlie game
        
        game.initTutorial(sceneNode: self, worldNode: worldNode, frame: self.frame,playerLives:3, physicsWorld:self.physicsWorld)
        player = game.getPlayer()
        //set physics
        physicsWorld.contactDelegate = self
        
        //tutorial instruction 1
        initObjectiveLabel(objectiveText: "Move your character by tilting your device")
        var waitAction = SKAction.wait(forDuration: 10)
        var initLabelAction = SKAction.run {
            self.initObjectiveLabel(objectiveText: "Click the screen to shoot ")
        }
        var sequenceAction = SKAction.sequence([waitAction, initLabelAction])
        run(sequenceAction)
        
        //tutorial instruction 2
         waitAction = SKAction.wait(forDuration: 18)
         initLabelAction = SKAction.run {
            self.initObjectiveLabel(objectiveText: "Destroy your enemies")
        }
         sequenceAction = SKAction.sequence([waitAction, initLabelAction])
        run(sequenceAction)
        
        //tutorial instruction 3
        waitAction = SKAction.wait(forDuration: 22)
        initLabelAction = SKAction.run {
            self.game.addRobot()
            self.worldNode.addChild(self.counterLabel)
       }
        sequenceAction = SKAction.sequence([waitAction, initLabelAction])
       run(sequenceAction)
       

    }
    
    func initObjectiveLabel(objectiveText:String){
        let surviveLabel = SKLabelNode(text: objectiveText)
         surviveLabel.fontSize = 50
         surviveLabel.fontColor = .white
         surviveLabel.position = CGPoint(x: size.width/2, y: size.height/2)
         surviveLabel.zRotation = -1*CGFloat.pi / 2.0
         surviveLabel.fontName =  "Avenir-BlackObliqued"
        addChild(surviveLabel)
        
        
        
                // Make the label blink for 5 seconds using SKAction
         let colorizeAction = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
         let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
         let blinkAction = SKAction.sequence([colorizeAction, SKAction.fadeOut(withDuration: 0.5), uncolorizeAction, SKAction.fadeIn(withDuration: 0.5)])

        let repeatBlinkAction = SKAction.repeat(blinkAction, count: 10)
         surviveLabel.run(repeatBlinkAction)
        
        // Wait for 5 seconds, then remove the label
        let waitAction = SKAction.wait(forDuration: 5)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([waitAction, removeAction])
         surviveLabel.run(sequenceAction)
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        game.handleCollision(contact: contact, worldNode: worldNode, sceneNode:self)
        enemyDeadCount = game.getEnemiesKilled()
        let enemyCount = levelGoal - enemyDeadCount
        counterLabel.text = "Enemies Left: \(enemyCount)"
       
        print(enemyDeadCount)
        if(enemyCount == 0){
            print("clear")
            completeLevel(index: 0)
            game.handleLevelComplete(sceneNode: self, worldNode: worldNode)
        }
        
      
    }
    override func didSimulatePhysics() {
        game.physicsHandler(frame: self.frame)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == "nextLevelButton" {
            clearAudio(scene: self.children)
            let gameScene = GameScene(fileNamed: "LevelOneScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
        game.handleTouch(touches: touches, worldNode: worldNode, sceneNode: self, view: view!)
        
        
    }
}
