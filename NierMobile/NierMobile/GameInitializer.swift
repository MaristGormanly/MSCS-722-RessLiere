//
//  GameInitializer.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//


import SpriteKit
import CoreMotion
    
class GameInitializer{
    //player
    var player:SKSpriteNode!
    var playerLivesList: [SKSpriteNode] = []
    
    var pauseGameButton:SKSpriteNode!
    var quitGameButton:SKSpriteNode!
    
    //pause toggle
    var gamePaused = false
    
    var backgroundMusic: SKAudioNode!
    
    var starfield:SKEmitterNode!
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    



    
    func getPlayer() -> SKSpriteNode {
           return player
       }
    
    func initPlayer(playerCategory:UInt32, robotCategory:UInt32,worldNode:SKNode,frame:CGRect){
        //create a player
        player = SKSpriteNode(imageNamed: "spaceship2")
        player.setScale(0.2)
       
        //player physics body
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/3)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = robotCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.affectedByGravity = false
        player.zRotation = -1*CGFloat.pi / 2.0

        
        //set player intial postiion
        player.position =  CGPoint(x: frame.size.width * 0.2, y: frame.height / 2)

        //add player to screen
        worldNode.addChild(player)
    }
    
   
    func initPlayerLives(worldNode:SKNode,frame:CGRect,view:SKView, playerLives:Int){
        var spacing = 0.94
        for i in 0...(playerLives-1) {
            playerLivesList.append(SKSpriteNode(imageNamed: "spaceship2"))
            playerLivesList[i].setScale(0.1)
            playerLivesList[i].zRotation = -1*CGFloat.pi / 2.0

            playerLivesList[i].position = CGPoint(x:frame.width * 0.85, y:frame.height * spacing)
            spacing -= 0.03
            worldNode.addChild(playerLivesList[i])
        }
    }
    
    func initPauseScreen(sceneNode:SKNode,frame:CGRect){
        //set pause button
        
        pauseGameButton = SKSpriteNode(imageNamed: "pause-game")
        
        pauseGameButton.name = "pauseGameButton"
        pauseGameButton.zRotation = -1*CGFloat.pi / 2.0
        pauseGameButton.setScale(1)
        pauseGameButton.position = CGPoint(x:frame.width * 0.85, y:frame.height * 0.08)
        
        sceneNode.addChild(pauseGameButton)
        
        quitGameButton = SKSpriteNode(imageNamed:"quit-game")
        quitGameButton.zRotation = -1*CGFloat.pi / 2.0
        quitGameButton.position = CGPoint(x:frame.width / 2, y:frame.height / 2)
        quitGameButton.name = "quitGameButton"
        
        //makes it the highest z value in the scene
      
        quitGameButton.zPosition = 5
        
    }
    func pauseButtonHandler(worldNode:SKNode, view:SKView){
       
        gamePaused = !gamePaused
        if gamePaused {
            // Pause the game
            worldNode.isPaused = true
           // gameTimer.invalidate()
            //backgroundMusic.run(SKAction.pause())
            worldNode.addChild(quitGameButton)
            
        } else {
            // Unpause the game
            worldNode.isPaused = false
            quitGameButton.removeFromParent()
           // gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)
           // backgroundMusic.run(SKAction.play())
        }
        
    }
    
    func initStarfield(worldNode:SKNode, frame:CGRect){
        //initlize startfield
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //initlize postion for starfield
        //TODO: add later to detect for device for placing start field
        starfield.position = CGPoint(x:frame.maxX, y: frame.height / 2)
        //skip 10 seconds into animation
        starfield.advanceSimulationTime(10)
        //add starfield to screen
        worldNode.addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
    }
    
    func handleMotion(){
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
               
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
               self.yAcceleration = CGFloat(acceleration.y) * 0.75 + self.yAcceleration * 0.25
            }
        }
        
    }
    func physicsHandler(frame:CGRect) {
     
        player.position.x += xAcceleration * 50
        player.position.y += yAcceleration * 50
        
        //stops player from going past walls of screeen
        if player.position.x > frame.width * 0.85 {
            player.position = CGPoint(x:frame.width * 0.85, y: player.position.y)
        }
        else if player.position.x < frame.width * 0.15{
            player.position = CGPoint(x: frame.width * 0.15, y: player.position.y)
        }
        if player.position.y > frame.height * 0.9 {
                    player.position = CGPoint(x:player.position.x, y:frame.height * 0.9)
                }
                else if player.position.y < frame.height * 0.1{
                    player.position = CGPoint(x: player.position.x, y: frame.height * 0.1)
                }
        
       
    }
}
