//
//  GameScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/23/23.
//


//TODO: ADD TIMER AND CHANGE COLOR WHEN LOW AND PLAY SOUNDS EFFECT
import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation


//REFERENCE
//MOHAWK ROBOT
//https://foozlecc.itch.io/mohawk-robot
//UFO ROBOT SPRITE https://opengameart.org/content/ufo-enemy-game-character
// CUTE ROBOT SPRITE https://www.youtube.com/watch?v=w_-Hed4r5PE
///
///HELPER FUNCTIONS FROM https://www.kodeco.com/71-spritekit-tutorial-for-beginners shooting projectiles section
///

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}



#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

func pointAtDistanceFromPoint(origin: CGPoint,target:CGPoint, distance: CGFloat) -> CGPoint {
    let x1 = origin.x
    let y1 = origin.y
    
    let x2 = target.x
    let y2 = target.y
    
    let slope = (y2 - y1) / (x2 - x1)
    //calculate slope
    
    
    
    let x3 = x1 + sqrt(pow(distance, 2) / (1 + pow(slope, 2)))
     let y3 = y1 + slope * (x2 - x1)
    
  
    return CGPoint(x: x3, y: y3)
}

func pointAlongLine(from start: CGPoint, to end: CGPoint, at distance: CGFloat) -> CGPoint {
    // Calculate the vector from start to end
    let vector = CGVector(dx: end.x - start.x, dy: end.y - start.y)
    
    // Normalize the vector
    let unitVector = CGVector(dx: vector.dx / vector.length(), dy: vector.dy / vector.length())
    
    // Calculate the new point along the line at the specified distance
    let newX = start.x + (unitVector.dx * distance)
    let newY = start.y + (unitVector.dy * distance)
    
    return CGPoint(x: newX, y: newY)
}

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //PROPTERTIES
    //seperate gameNode from scene
    let worldNode = SKNode()
    
    
    
    // ! is optional meaning value does not have be defined right away
    var player:SKSpriteNode!
    var starfield:SKEmitterNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //game timer
    var gameTimer:Timer!
    var spawnInterval: TimeInterval = 0.75
    let timeIntervalDecrement: TimeInterval = 0.01
    
    //last torpedo shoot
    var lastTorpedoFiredTime: TimeInterval = 0

    
    //POSSIBLE targets
    var possiblerobots = ["robot","robot2","robot3"]
    
    //TODO: bitwise defines each robot and projectile
    let robotCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let playerCategory: UInt32 = 0x1 << 2
    
    //motion mangaer
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    //music
    var backgroundMusic: SKAudioNode!
    
    
    //player
    var currentRotation: CGFloat = 0
    
    //player lives
    
    var playerLives = 3
    var playerLivesList: [SKSpriteNode] = []

    
    //intialize pause button
    var pauseGameButton:SKSpriteNode!
    var gamePause = false
    var quitGameButton:SKSpriteNode!
   
    
    //called when scene is presented in view for first time
    override func didMove(to view: SKView) {
        
        addChild(worldNode)
       
        //play music
        
        playMusic()
       
       //add starfield
        initStarfield()
        
       //add player
        initPlayer()
        
        //init pause screen
        initPauseScreen()
       
        //set physics for scene zero gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //sets physics rules for contact to be defined in contact delegate function
        self.physicsWorld.contactDelegate = self
        
        //creates score board
        initScore()
        
        initPlayerLives()
        
        gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)
        
        
        //haddle motion
        handleMotion()
       
    }
    
    func initPlayer(){
        //create a player
        player = SKSpriteNode(imageNamed: "spaceship2")
        player.setScale(0.2)
        player.zRotation = -1*CGFloat.pi / 2.0
        
        //player physics body
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = robotCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.affectedByGravity = false

        
        //set player intial postiion
        player.position = CGPoint(x: self.frame.size.width * 0.08, y: self.frame.height / 2)
        //add player to screen
        worldNode.addChild(player)
    }
    
    //TODO: Diffculty adjust lives
    func initPlayerLives(){
        var spacing = 0.94
        for i in 0...(playerLives-1) {
            playerLivesList.append(SKSpriteNode(imageNamed: "spaceship2"))
            playerLivesList[i].zRotation = -1*CGFloat.pi / 2.0
            playerLivesList[i].setScale(0.1)
            playerLivesList[i].position = CGPoint(x:self.frame.width * 0.85, y:self.frame.height * spacing )
            spacing -= 0.03
            worldNode.addChild(playerLivesList[i])
        }
     
        
    }
    
    func initPauseScreen(){
        //set pause button
        
        pauseGameButton = SKSpriteNode(imageNamed: "pause-game")
        
        pauseGameButton.name = "pauseGameButton"
        pauseGameButton.zRotation = -1*CGFloat.pi / 2.0
        pauseGameButton.setScale(1)
        pauseGameButton.position = CGPoint(x:self.frame.width * 0.85, y:self.frame.height * 0.08)
        
        self.addChild(pauseGameButton)
        
        quitGameButton = SKSpriteNode(imageNamed:"quit-game")
        quitGameButton.zRotation = -1*CGFloat.pi / 2.0
        quitGameButton.position = CGPoint(x:self.frame.width / 2, y:self.frame.height / 2)
        quitGameButton.name = "quitGameButton"
        
        //makes it the highest z value in the scene
        let highestZPosition = 5
        quitGameButton.zPosition = 5
        
        
    }
    
    func playMusic(){
        //start music
        if let musicURL = Bundle.main.url(forResource: "hacking-dimension", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    }
    
    func initStarfield(){
        //initlize startfield
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //initlize postion for starfield
        //TODO: add later to detect for device for placing start field
        starfield.position = CGPoint(x:self.frame.maxX, y: self.frame.height + 100)
        //skip 10 seconds into animation
        starfield.advanceSimulationTime(10)
        //add starfield to screen
        worldNode.addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
    }
    
    func initScore(){
        //set the score label inital
        scoreLabel = SKLabelNode(text: "Score - 0")
        scoreLabel.zRotation = -1*CGFloat.pi / 2.0
        //TODO: add as ratio of screen rather than hard coded
        scoreLabel.position = CGPoint(x:self.frame.width * 0.85 , y: self.frame.height / 2)
    
        //http://iosfonts.com/
        scoreLabel.fontName = "Avenir-BlackOblique"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = UIColor.white
        score = 0
        worldNode.addChild(scoreLabel)
    }
    
    
    
    func handleMotion(){
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
               self.yAcceleration = CGFloat(acceleration.y) * 0.75 + self.yAcceleration * 0.25
            }
        }
        
    }
    
    //when scene changes remove backround music
    override func willMove(from view: SKView) {
    
        backgroundMusic?.removeFromParent()
    }
    
    
    //
    //
    //
    @objc func addRobot () {
        //increase spawning rate over time
        spawnInterval -= timeIntervalDecrement
            if spawnInterval < 0.4 {
                spawnInterval = 0.4
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
        worldNode.addChild(robot)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: -robot.size.width, y: position), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        robot.run(SKAction.sequence(actionArray)) // Run the sequence of actions on the node

                               
    }
    
    
    //
    //when screen touched missile is fired
    //
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        guard let touchLocation = touches.first?.location(in: self) else { return }
        
        // Find the node at the touch location
        let touchedNode = self.atPoint(touchLocation)
        
        // Check if the touched node is the node you're interested in
        if touchedNode.name == "pauseGameButton" {
            pauseButtonHandler()
        }
        else if touchedNode.name == "quitGameButton"{
            let homeScene = HomeScene(fileNamed: "HomeScene")
                            homeScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(homeScene!, transition: SKTransition.fade(withDuration: 0.5))
            
        }
        else if gamePause != true{
            
            // Position to rotate towards
            let currentTime = NSDate().timeIntervalSince1970
                let timeSinceLastTorpedo = currentTime - lastTorpedoFiredTime
                if timeSinceLastTorpedo < 0.25 { // Adjust this value to set the delay between torpedos
                    return
                }
            lastTorpedoFiredTime = currentTime
            let targetPosition = touch.location(in: self)
            //TODO: MAKE FURTHER ADJUSTMENTS TO do properly
            let torpedoTarget = pointAlongLine(from: player.position, to: targetPosition, at: 1000)
            
            //rotate player to where going to shoot

            let dx = targetPosition.x - player.position.x
            let dy = targetPosition.y - player.position.y
            
            // Calculate the angle between the sprite and the touch location
            let angle = atan2(dy, dx)
            
            // Set the sprite's zRotation to the calculated angle
            player.zRotation =  angle + 180
            
            fireTorpedo(target: torpedoTarget)
        }
        
        
       
    }
    
    //TODO: clean up the logic here
    //handles game pausing
    func pauseButtonHandler(){
        
        isPaused = !isPaused
        gamePause = isPaused
        if isPaused {
            // Pause the game
            worldNode.isPaused = true
            gameTimer.invalidate()
            backgroundMusic.run(SKAction.pause())
            worldNode.addChild(quitGameButton)
            
        } else {
            // Unpause the game
            self.view?.isPaused = false
            quitGameButton.removeFromParent()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addRobot), userInfo: nil, repeats: true)
            backgroundMusic.run(SKAction.play())
        }
        
    }
    
    
    //
    //collision detected on torpedo
    //
    func fireTorpedo(target:CGPoint) {
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
    
    //called when two physics bodies collid with each other
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
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
        //if missile hits robot
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & robotCategory) != 0 {
            torpedoDidCollideWithrobot(torpedoNode: firstBody.node as! SKSpriteNode, robotNode: secondBody.node as! SKSpriteNode)
        }
        //if robot hit player
        if (firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == robotCategory) ||
                   (firstBody.categoryBitMask == robotCategory && secondBody.categoryBitMask == playerCategory) {
                    // Play a sound effect or explosion animation
                    
                    // Decrement player health or trigger a game over
                    handlePlayerDamage()
                    
                    // Remove the robot from the scene
                    if let robotNode = firstBody.node as? SKSpriteNode {
                        playExplosion(spriteNode: robotNode)
                        robotNode.removeFromParent()
                    } else if let robotNode = secondBody.node as? SKSpriteNode {
                        playExplosion(spriteNode: robotNode)
                        robotNode.removeFromParent()
                    }
                }
    }
    
    func handlePlayerDamage(){
        if(playerLives > 0){
            playerLivesList[playerLives-1].removeFromParent()
            playerLives -= 1
        }
        else{
            print("Gameover")
        }
    }
    
    func torpedoDidCollideWithrobot (torpedoNode:SKSpriteNode, robotNode:SKSpriteNode) {
    
        playExplosion(spriteNode: robotNode)
        
        torpedoNode.removeFromParent()
        robotNode.removeFromParent()
        
        
       
        score += 5
        
    }
    
    override func didSimulatePhysics() {
     
        player.position.x += xAcceleration * 50
        player.position.y += yAcceleration * 50
        
        //stops player from going past walls of screeen
        if player.position.x > self.frame.width * 0.85 {
            player.position = CGPoint(x:self.frame.width * 0.85, y: player.position.y)
        }
        else if player.position.x < self.frame.width * 0.15{
            player.position = CGPoint(x: self.frame.width * 0.15, y: player.position.y)
        }
        if player.position.y > self.frame.height * 0.9 {
                    player.position = CGPoint(x:player.position.x, y:self.frame.height * 0.9)
                }
                else if player.position.y < self.frame.height * 0.1{
                    player.position = CGPoint(x: player.position.x, y: self.frame.height * 0.1)
                }
        
       
    }
    
    //tale a sprite and creates a explosion on its position
    func playExplosion(spriteNode:SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = spriteNode.position
        worldNode.addChild(explosion)
        
        worldNode.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        worldNode.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
    }
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
