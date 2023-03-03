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
                var firstBody:SKPhysicsBody
                var secondBody:SKPhysicsBody
        print("test")
//        print(contact.bodyA)
//        print("BodyB")
//        print(contact.bodyB)
                
                if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                    firstBody = contact.bodyA
                    secondBody = contact.bodyB
                }else if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask{
                    firstBody = contact.bodyB
                    secondBody = contact.bodyA
                }
                // occasinally return nil if two object get hit at same time
                else{
                    return
                }
        if (firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == robotCategory) ||
                   (firstBody.categoryBitMask == robotCategory && secondBody.categoryBitMask == playerCategory) {
                    // Play a sound effect or explosion animation
                    
                    // Decrement player health or trigger a game over
                    game.handlePlayerDamage(sceneNode:self,worldNode:worldNode)
                    
                    // Remove the robot from the scene
            // Remove the robot from the scene
            if firstBody.categoryBitMask == robotCategory {
                if let robotNode = firstBody.node as? SKSpriteNode {
                    game.playExplosion(spriteNode: robotNode,worldNode: worldNode)
                    print("fist body")
                    print(robotNode)
                    robotNode.removeFromParent()
                }
            }
            else if secondBody.categoryBitMask == robotCategory {
                if let robotNode = secondBody.node as? SKSpriteNode {
                    game.playExplosion(spriteNode: robotNode,worldNode: worldNode)
                    print(robotNode)
                   robotNode.removeFromParent()
                }
            }
                        }
        else{
            //if nill returns
            guard let torpedoNode = firstBody.node as? SKSpriteNode, let robotNode = secondBody.node as? SKSpriteNode else {
                return
            }
            game.laserDidCollideWithRobot(torpedoNode: torpedoNode, robotNode: robotNode, worldNode: worldNode)

        }
    }
    
    override func didSimulatePhysics() {
        game.physicsHandler(frame: self.frame)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        guard let touchLocation = touches.first?.location(in: self) else { return }
        
        // Find the node at the touch location
        let touchedNode = self.atPoint(touchLocation)
        let targetPosition = touch.location(in: self)

        
        // Check if the touched node is the node you're interested in
        if touchedNode.name == "pauseGameButton" {
            game.pauseButtonHandler(worldNode: worldNode, view: view!)
        }
        else if touchedNode.name == "quitGameButton"{
            let homeScene = HomeScene(fileNamed: "HomeScene")
                            homeScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(homeScene!, transition: SKTransition.fade(withDuration: 0.5))
            
        }
        else if !game.getGamePaused(){
            game.handleShoot(targetPosition:targetPosition,worldNode:worldNode)
           
        }
        
    }
    
   
    
    
 
    
}
