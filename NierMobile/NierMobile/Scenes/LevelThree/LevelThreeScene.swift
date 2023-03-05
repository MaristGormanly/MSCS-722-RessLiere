//
//  LevelOneScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//

import SpriteKit
import GameplayKit

class LevelThreeScene: SKScene, SKPhysicsContactDelegate {
      let game = GameInitializer()
    //TODO: maybe getter and setter for this
      let robotCategory:UInt32 = 0x1 << 1
      let photonTorpedoCategory:UInt32 = 0x1 << 0
      let playerCategory: UInt32 = 0x1 << 2
      let worldNode = SKNode()
      var spawnInterval: TimeInterval = 0.75
    
  
      let timeIntervalDecrement: TimeInterval = 0.01
      var gameTimer:Timer!
      var gameTimerIndx:Int!
    var   timeRemaining:Int =  10// 1 minute
      var robotTimerIndx:Int!
      var timerDuration: TimeInterval = 10
        var isTimerRunning = false
    var timerLabel:SKLabelNode!
      //POSSIBLE targets
      var possiblerobots = ["robot","robot2","robot3"]
    
      var player:SKSpriteNode!
    
    var timer: Timer?

    
    

        

    
    override func didMove(to view: SKView) {
            addChild(worldNode)
           
        //TODO: Create initalze game function
       
        game.initGame(sceneNode: self, worldNode: worldNode, frame: self.frame,playerLives:3, physicsWorld:self.physicsWorld)
        physicsWorld.contactDelegate = self
        player = game.getPlayer()
        //set physics for scene zero gravity
        //set physics
      //  gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)
       // gameTimerIndx = game.addTimer(timer: gameTimer)
        // Create the label and set its properties
        
        initLevelCountDown()
        initObjectiveLabel()
        
       

       }
    
    func initObjectiveLabel(){
        let surviveLabel = SKLabelNode(text: "Destroy the enemy before time runs out")
         surviveLabel.fontSize = 50
         surviveLabel.fontColor = .white
         surviveLabel.position = CGPoint(x: size.width/2, y: size.height/2)
         surviveLabel.zRotation = -1*CGFloat.pi / 2.0
         surviveLabel.fontName =  "Helvetica-Bold"
        addChild(surviveLabel)
        
                // Make the label blink for 5 seconds using SKAction
         let colorizeAction = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5)
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
    
    
    func initLevelCountDown(){
        timerLabel = SKLabelNode(text: "\(Int(timerDuration))")
        timerLabel.position = CGPoint(x: self.frame.width * 0.88, y: self.frame.height / 2)
        timerLabel.zRotation = -1*CGFloat.pi / 2.0
        timerLabel.fontName = "Helvetica-Bold"
        timerLabel.fontSize = 24
        addChild(timerLabel)
        
        
       

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.timeRemaining -= 1
            
                self.timerLabel.text = "\(self.timeRemaining)"
            
                if self.timeRemaining == 0 {
                timer.invalidate()
                // perform other actions here
                self.timerCompleted()
                completeLevel(index: 0)
            }
           
        }
        isTimerRunning = true
    }
    
    
    func timerCompleted() {
        print("complete")
        // Stop spawning robots
        if(gameTimer != nil){
            gameTimer.invalidate()
        }
        
        // Remove all existing robots from the scene
        worldNode.enumerateChildNodes(withName: "robot") { node, _ in
            node.removeFromParent()
        }
        
        game.handleGameOver(sceneNode: self, worldNode: worldNode)

    }

        
    func didBegin(_ contact: SKPhysicsContact) {
        game.handleCollision(contact: contact, worldNode: worldNode, sceneNode:self)
    }
    
    override func didSimulatePhysics() {
        game.physicsHandler(frame: self.frame)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == "nextLevelButton" {
            let gameScene = GameScene(fileNamed: "LevelTwoScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
        if nodesArray.first?.name == "pauseGameButton" {
            if isTimerRunning {
                   // Pause the timer
                   timer?.invalidate()
                   isTimerRunning = false
               } else {
                   // Start the timer
                   timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                       self.timeRemaining -= 1
                       self.timerLabel.text = "\(self.timeRemaining)"
                       if self.timeRemaining == 0 {
                           timer.invalidate()
                           self.timerCompleted()
                           completeLevel(index: 0)
                       }
                   }
                   isTimerRunning = true
               }
        }
        game.handleTouch(touches: touches, worldNode: worldNode, sceneNode: self, view: view!)
        
    }
    
   
    
    
 
    
}

