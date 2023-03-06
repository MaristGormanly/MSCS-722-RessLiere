//
//  LevelTwoScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/4/23.
//

import SpriteKit
import GameplayKit

class LevelTwoScene:SKScene, SKPhysicsContactDelegate {
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
    var startingTime = 10// 1 minute
    var robotTimerIndx:Int!
    var timerDuration: TimeInterval = 10

    //POSSIBLE targets
    var possiblerobots = ["robot","robot2","robot3"]
  
    var player:SKSpriteNode!
    var levelGoal:Int = 75
    var enemyDeadCount: Int  = 0
    var counterLabel: SKLabelNode!

  
  

      

  
  override func didMove(to view: SKView) {
          addChild(worldNode)
         
      //TODO: Create initalze game function
     
      game.initGame(sceneNode: self, worldNode: worldNode, frame: self.frame,playerLives:3, physicsWorld:self.physicsWorld)
      physicsWorld.contactDelegate = self
      player = game.getPlayer()
      //set physics for scene zero gravity
      //set physics
     
      // Create the label and set its properties
      
      

      
      initObjectiveLabel()
      
      counterLabel = SKLabelNode(text: "KILL  \(levelGoal) ")
      counterLabel.fontSize = 50
      counterLabel.fontName = "Avenir-BlackOblique"
      counterLabel.zRotation =  -1*CGFloat.pi / 2.0
      counterLabel.fontColor = .white
      counterLabel.position = CGPoint(x: self.frame.width * 0.85 , y: self.frame.height / 2)
      addChild(counterLabel)

     }
  
  func initObjectiveLabel(){
      let surviveLabel = SKLabelNode(text: "DESTROY THE ENEMY")
       surviveLabel.fontSize = 50
       surviveLabel.fontColor = .white
       surviveLabel.position = CGPoint(x: size.width/2, y: size.height/2)
       surviveLabel.zRotation = -1*CGFloat.pi / 2.0
       surviveLabel.fontName =  "Avenir-BlackOblique"
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
  
  
 
  
  func didBegin(_ contact: SKPhysicsContact) {
      game.handleCollision(contact: contact, worldNode: worldNode, sceneNode:self)
      enemyDeadCount = game.getEnemiesKilled()
      let enemyCount = levelGoal - enemyDeadCount
      counterLabel.text = "\(enemyCount)"
     
      print(enemyDeadCount)
      if(enemyCount == 0){
          print("clear")
          completeLevel(index: 2)
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
          let gameScene = GameScene(fileNamed: "LevelThreeScene")
                          gameScene?.scaleMode = .aspectFill
                          self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
      }
      game.handleTouch(touches: touches, worldNode: worldNode, sceneNode: self, view: view!)
      
      
  }
  
 
}
