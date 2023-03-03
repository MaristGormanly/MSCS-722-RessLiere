//
//  GameInitializer.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//


import SpriteKit
import CoreMotion
    
class GameInitializer{
    
    let robotCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let playerCategory: UInt32 = 0x1 << 2
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
    
    //last torpedo shoot
    var lastTorpedoFiredTime: TimeInterval = 0


    
    func getPlayer() -> SKSpriteNode {
           return player
       }
    func getGamePaused() -> Bool{
        return gamePaused
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
        player.position =  CGPoint(x: frame.size.width * 0.08, y: frame.height / 2)

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
    
    //TODO: takes a timer a halts if there is a timer
    func pauseButtonHandler(worldNode:SKNode, view:SKView){
        gamePaused = !gamePaused
        if gamePaused {
            // Pause the game
            worldNode.isPaused = true
           // gameTimer.invalidate()
            backgroundMusic.run(SKAction.pause())
            worldNode.addChild(quitGameButton)
            
        } else {
            // Unpause the game
            worldNode.isPaused = false
            quitGameButton.removeFromParent()
           // gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)
            backgroundMusic.run(SKAction.play())
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
    
    
    //tale a sprite and creates a explosion on its position
    func playExplosion(spriteNode:SKSpriteNode,worldNode:SKNode){
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = spriteNode.position

        worldNode.addChild(explosion)
        
        worldNode.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        worldNode.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
    }
    
    func handleShoot(targetPosition:CGPoint,worldNode:SKNode){
        // Position to rotate towards
        let currentTime = NSDate().timeIntervalSince1970
            let timeSinceLastTorpedo = currentTime - lastTorpedoFiredTime
            if timeSinceLastTorpedo < 0.25 { // Adjust this value to set the delay between torpedos
                return
            }
        lastTorpedoFiredTime = currentTime
        //TODO: MAKE FURTHER ADJUSTMENTS TO do properly
        let torpedoTarget = pointAlongLine(from: player.position, to: targetPosition, at: 1000)
        
        //rotate player to where going to shoot

        let dx = targetPosition.x - player.position.x
        let dy = targetPosition.y - player.position.y
        
        // Calculate the angle between the sprite and the touch location
        let angle = atan2(dy, dx)
        
        // Set the sprite's zRotation to the calculated angle
        player.zRotation =  angle + 180
        
        fireTorpedo(target: torpedoTarget,worldNode: worldNode)
    }
    
    func fireTorpedo(target:CGPoint,worldNode:SKNode) {
        worldNode.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo2")
        torpedoNode.position = player.position
        //TODO: check degrees of ship
       
        
        let playerFacingAngle = player.zRotation + 60
        
        //calculates cordinate to spawn torpedo away from player can be increased by increasing constant in this case 60
        let torpedoOffset = CGVector(dx: 60 * sin(playerFacingAngle) , dy: -60 * cos(playerFacingAngle))
        torpedoNode.position = CGPoint(x: player.position.x + torpedoOffset.dx, y: player.position.y + torpedoOffset.dy)

        
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = robotCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        worldNode.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.5
       
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: target.x  , y: target.y ), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    func playMusic(worldNode:SKNode){
        //start music
        if let musicURL = Bundle.main.url(forResource: "hacking-dimension", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.autoplayLooped = true
            worldNode.addChild(backgroundMusic)
        }
    }
    
    func initGame(sceneNode:SKNode,worldNode:SKNode,frame:CGRect){
        initPlayer(playerCategory: playerCategory, robotCategory: robotCategory, worldNode: worldNode, frame: frame)
        initStarfield(worldNode: worldNode, frame: frame)
        playMusic(worldNode: worldNode)
        initPauseScreen(sceneNode: sceneNode, frame: frame)
        handleMotion()
    }
}
