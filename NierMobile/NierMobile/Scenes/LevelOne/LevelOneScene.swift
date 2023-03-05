//
//  LevelOneScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//

import SpriteKit
import GameplayKit

class LevelOneScene: SKScene, SKPhysicsContactDelegate {
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
    
      

    
    

        

    
    override func didMove(to view: SKView) {
            addChild(worldNode)
           
        //TODO: Create initalze game function
       
        game.initGame(sceneNode: self, worldNode: worldNode, frame: self.frame,playerLives:3, physicsWorld:self.physicsWorld)
        physicsWorld.contactDelegate = self
        player = game.getPlayer()
        //set physics for scene zero gravity
        //set physics
        gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)
        gameTimerIndx = game.addTimer(timer: gameTimer)
        // Create the label and set its properties
        
        initLevelCountDown()
        initObjectiveLabel()
        
       

       }
    
    func initObjectiveLabel(){
        let surviveLabel = SKLabelNode(text: "SURVIVE")
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
        let timerLabel = SKLabelNode(text: "\(Int(timerDuration))")
        timerLabel.position = CGPoint(x: self.frame.width * 0.88, y: self.frame.height / 2)
        timerLabel.zRotation = -1*CGFloat.pi / 2.0
        timerLabel.fontName = "Helvetica-Bold"
        timerLabel.fontSize = 24
        addChild(timerLabel)
        
        
        var timeRemaining = startingTime

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeRemaining -= 1
            timerLabel.text = "\(timeRemaining)"
            
            if timeRemaining == 0 {
                timer.invalidate()
                // perform other actions here
                self.timerCompleted()
                completeLevel(index: 0)
            }
            self.game.addTimer(timer: timer)
        }
    }
    
    
    func timerCompleted() {
        print("complete")
        // Stop spawning robots
        gameTimer.invalidate()
        
        // Remove all existing robots from the scene
        worldNode.enumerateChildNodes(withName: "robot") { node, _ in
            node.removeFromParent()
        }
        
        game.handleLevelComplete(sceneNode: self, worldNode: worldNode)

    }

    @objc func addRobot () {
        //increase spawning rate over time
        spawnInterval -= timeIntervalDecrement
            if spawnInterval < 0.2 {
                spawnInterval = 0.2
            }
        gameTimer.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)

     
        //generates a random element from possible robot array
        possiblerobots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possiblerobots) as! [String]
        
        let robot = SKSpriteNode(imageNamed: possiblerobots[0])
        
        //generates lowest x and y value
        let randomPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.height))

        let position = CGFloat(randomPosition.nextInt())
        robot.name = "robot"
        robot.position = CGPoint(x: self.frame.size.width + robot.size.width, y: position)
        robot.size = CGSize(width: 100, height: 100)
        //sets size of the spawned robot
        robot.physicsBody = SKPhysicsBody(rectangleOf: robot.size)
        //TODO:explore what this means
        robot.physicsBody?.isDynamic = true
        
        //calculates when robot is hit
        robot.physicsBody?.categoryBitMask = robotCategory
        robot.physicsBody?.contactTestBitMask = photonTorpedoCategory
        robot.physicsBody?.collisionBitMask = 0
        
        //calculates when robot hits player
        robot.physicsBody?.contactTestBitMask = playerCategory
        robot.physicsBody?.collisionBitMask = 0
        
        robot.zRotation = -1*CGFloat.pi / 2.0
        //robots back of screen
        robot.zPosition = -5
        worldNode.addChild(robot)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: -robot.size.width, y: position), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        robot.run(SKAction.sequence(actionArray)) // Run the sequence of actions on the node

                               
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
        game.handleTouch(touches: touches, worldNode: worldNode, sceneNode: self, view: view!)
        
    }
    
   
    
    
 
    
}
