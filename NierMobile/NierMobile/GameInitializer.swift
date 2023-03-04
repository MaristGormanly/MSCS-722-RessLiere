//
//  GameInitializer.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//

//art https://www.pngkey.com/detail/u2e6a9w7t4w7t4o0_1443321603011-pixel-home-button-png/
import SpriteKit
import CoreMotion
    
class GameInitializer{
    
    let robotCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let playerCategory: UInt32 = 0x1 << 2
    //player
    var player:SKSpriteNode!
    var playerLives:Int = 3
    var playerLivesList: [SKSpriteNode] = []
    
    var pauseGameButton:SKSpriteNode!
    var quitGameButton:SKSpriteNode!
    var levelCompletedLabel:SKLabelNode!
    var returnHomeButton:SKSpriteNode!
    
    //pause toggle
    var gamePaused = false
    var gameOver = false
    
    
    var backgroundMusic: SKAudioNode!
    
    var starfield:SKEmitterNode!
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    //last torpedo shoot
    var lastTorpedoFiredTime: TimeInterval = 0
    
    var timerList = [Timer]()
    
    
    
    func getPlayer() -> SKSpriteNode {
        return player
    }
    func getGamePaused() -> Bool{
        return gamePaused
    }
    
    //adds a timer to timer list and returns its index
    func addTimer(timer: Timer) -> Int {
        timerList.append(timer)
        return timerList.count - 1
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
    
    func initLevelComplete(worldNode:SKNode, frame:CGRect){
         levelCompletedLabel = SKLabelNode(fontNamed: "PressStart2P-Regular")
        levelCompletedLabel.fontSize = 48
        levelCompletedLabel.text = "LEVEL COMPLETED"
        levelCompletedLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        levelCompletedLabel.zRotation = -1*CGFloat.pi / 2.0
        levelCompletedLabel.name = "levelCompleteButton"
        levelCompletedLabel.color = .white
        levelCompletedLabel.colorBlendFactor = 1.0
        
        returnHomeButton = SKSpriteNode(imageNamed:"return-home")
      
        returnHomeButton.position = CGPoint(x: frame.width * 0.35 , y: frame.height * 0.6)
        returnHomeButton.setScale(0.75)
        returnHomeButton.zRotation = -1*CGFloat.pi / 2.0
        levelCompletedLabel.name = "returnHomeButton"
       
        
    }
    
    
    func initPlayerLives(worldNode:SKNode,frame:CGRect, pLives:Int){
        var spacing = 0.94
        playerLives = pLives
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
            for timer in timerList {
                timer.invalidate()
            }
            worldNode.addChild(quitGameButton)
            
            
        } else {
            // Unpause the game
            worldNode.isPaused = false
            quitGameButton.removeFromParent()
            for timer in timerList {
                timer.fire()
            }
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
        if(!gamePaused){
            player.position.x += xAcceleration * 50
            player.position.y += yAcceleration * 50
        }
        
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
    
    func fireLaser(target:CGPoint,worldNode:SKNode) {
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
        
        fireLaser(target: torpedoTarget,worldNode: worldNode)
    }
    
    func handlePlayerDamage(sceneNode:SKNode, worldNode:SKNode){
        if(playerLives > 1){
            playerLivesList[playerLives-1].removeFromParent()
            playerLives -= 1
            // Check if this is the last life
            if(playerLives == 1){
                // Make the player's last life blink
                let blinkAction = SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.fadeIn(withDuration: 0.5)]))
                playerLivesList[0].run(blinkAction)
            }
        }
        else{
            handleGameOver(sceneNode: sceneNode, worldNode: worldNode)
        }
    }

    
    func handleGameOver(sceneNode:SKNode, worldNode:SKNode){
        playExplosion(spriteNode: player,worldNode: worldNode)
        playerLivesList[playerLives-1].removeFromParent()
        player.removeFromParent()
        // scoreLabel.position = CGPoint(x: self.frame.width / 3, y:self.frame.height / 2)
        backgroundMusic.run(SKAction.pause())
        sceneNode.run(SKAction.playSoundFileNamed("game-over.mp3", waitForCompletion: true))
        let wait = SKAction.wait(forDuration: 2.0)
        pauseGameButton.removeFromParent()
        //  gameTimer.invalidate()
        worldNode.addChild(quitGameButton)
        gameOver = true
        //stops all game timers
        if(!timerList.isEmpty){
            for timer in timerList {
                timer.invalidate()
            }
        }

        sceneNode.run(wait) {
            
            worldNode.isPaused = true
            
        }
    }
    
    func handleTouch(touches:Set<UITouch>, worldNode:SKNode,sceneNode:SKNode, view:SKView){
        guard let touch = touches.first else {
            return
        }
        guard let touchLocation = touches.first?.location(in: sceneNode) else { return }
        
        // Find the node at the touch location
        let touchedNode = sceneNode.atPoint(touchLocation)
        let targetPosition = touch.location(in: sceneNode)
        
        // Check if the touched node is the node you're interested in
        if touchedNode.name == "pauseGameButton" {
            pauseButtonHandler(worldNode: worldNode, view: view)
        }
        else if touchedNode.name == "quitGameButton"{
            let homeScene = HomeScene(fileNamed: "HomeScene")
                            homeScene?.scaleMode = .aspectFill
                            sceneNode.scene?.view?.presentScene(homeScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
        else if touchedNode.name == "returnHomeButton"{
            let homeScene = HomeScene(fileNamed: "HomeScene")
                            homeScene?.scaleMode = .aspectFill
                            sceneNode.scene?.view?.presentScene(homeScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        else if !gamePaused && !gameOver{
            handleShoot(targetPosition:targetPosition,worldNode:worldNode)
           
        }
    }
        
    //TODO: handle level complete
    func handleGameClear(sceneNode:SKNode, worldNode:SKNode){
       
        playerLivesList[playerLives-1].removeFromParent()
        player.removeFromParent()
        // scoreLabel.position = CGPoint(x: self.frame.width / 3, y:self.frame.height / 2)
        backgroundMusic.run(SKAction.pause())
        sceneNode.run(SKAction.playSoundFileNamed("game-over.mp3", waitForCompletion: true))
        let wait = SKAction.wait(forDuration: 2.0)
        pauseGameButton.removeFromParent()
        //  gameTimer.invalidate()
        worldNode.addChild(levelCompletedLabel)
        worldNode.addChild(returnHomeButton)
        gameOver = true
        worldNode.enumerateChildNodes(withName: "robot") { (node, _) in
             if let robot = node as? SKSpriteNode {
                 self.playExplosion(spriteNode: robot, worldNode: worldNode)
                 robot.removeFromParent()
             }
         }
        //stops all game timers
        if(!timerList.isEmpty){
            for timer in timerList {
                timer.invalidate()
            }
        }

        sceneNode.run(wait) {
            
            worldNode.isPaused = true
            
        }
    }
        
        
        func laserDidCollideWithRobot(torpedoNode:SKSpriteNode, robotNode:SKSpriteNode,worldNode:SKNode) {
            playExplosion(spriteNode: robotNode,worldNode: worldNode)
            torpedoNode.removeFromParent()
            robotNode.removeFromParent()
        }
        
        func playMusic(worldNode:SKNode){
            //start music
            if let musicURL = Bundle.main.url(forResource: "hacking-dimension", withExtension: "mp3") {
                backgroundMusic = SKAudioNode(url: musicURL)
                backgroundMusic.autoplayLooped = true
                worldNode.addChild(backgroundMusic)
            }
        }
    
    func handleCollision(contact: SKPhysicsContact,worldNode:SKNode,sceneNode:SKNode){
            var firstBody:SKPhysicsBody
            var secondBody:SKPhysicsBody
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }
            else if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask{
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
                handlePlayerDamage(sceneNode:sceneNode,worldNode:worldNode)
                
                // Remove the robot from the scene
        // Remove the robot from the scene
        if firstBody.categoryBitMask == robotCategory {
            if let robotNode = firstBody.node as? SKSpriteNode {
                playExplosion(spriteNode: robotNode,worldNode: worldNode)
                print(robotNode)
                
            }
        }
        else if secondBody.categoryBitMask == robotCategory {
            if let robotNode = secondBody.node as? SKSpriteNode {
                playExplosion(spriteNode: robotNode,worldNode: worldNode)
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
        laserDidCollideWithRobot(torpedoNode: torpedoNode, robotNode: robotNode, worldNode: worldNode)

    }
    }
   
        func initGame(sceneNode:SKNode,worldNode:SKNode,frame:CGRect,playerLives:Int,physicsWorld:SKPhysicsWorld){
            initPlayer(playerCategory: playerCategory, robotCategory: robotCategory, worldNode: worldNode, frame: frame)
            initPlayerLives(worldNode: worldNode, frame: frame, pLives: playerLives)
            initStarfield(worldNode: worldNode, frame: frame)
            playMusic(worldNode: worldNode)
            initPauseScreen(sceneNode: sceneNode, frame: frame)
            initLevelComplete(worldNode: worldNode, frame: frame)
            handleMotion()
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
           
        }
    }

