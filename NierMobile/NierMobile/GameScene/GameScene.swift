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
    var gameTimer:Timer!
    
    //POSSIBLE targets
    var possiblerobots = ["robot","robot2","robot3"]
    
    //TODO: bitwise defines each robot and projectile
    let robotCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    //motion mangaer
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    //music
    var backgroundMusic: SKAudioNode!
    
    
    //player
    var currentRotation: CGFloat = 0
    
    //intialize pause button
    var pauseGameButton:SKSpriteNode!
    var gamePause = false
    //
    //
    //
    override func didMove(to view: SKView) {
        
        addChild(worldNode)
       
        //start music
        if let musicURL = Bundle.main.url(forResource: "hacking-dimension", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
        
        //initlize startfield
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //initlize postion for starfield
        //TODO: add later to detect for device for placing start field
        starfield.position = CGPoint(x:view.frame.maxX, y: self.frame.height + 100)
        //skip 10 seconds into animation
        starfield.advanceSimulationTime(10)
        //add starfield to screen
        worldNode.addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
        
        //create a player
        player = SKSpriteNode(imageNamed: "spaceship2")
        player.setScale(0.2)
        player.zRotation = -1*CGFloat.pi / 2.0
        
        //set player intial postiion
        player.position = CGPoint(x: self.frame.size.width * 0.08, y: self.frame.height / 2)
        //add player to screen
        worldNode.addChild(player)
        
        //set pause button
        
        pauseGameButton = SKSpriteNode(imageNamed: "pause-game")
        
        pauseGameButton.name = "pauseGameButton"
        pauseGameButton.zRotation = -1*CGFloat.pi / 2.0
        pauseGameButton.setScale(1)
        pauseGameButton.position = CGPoint(x:self.frame.width * 0.85, y:self.frame.height * 0.08)
        
        self.addChild(pauseGameButton)
        
       
        
        //set physics for scene zero gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //sets physics rules for contact
        //TODO: contact delegate will be defined
        self.physicsWorld.contactDelegate = self
        
        
        
        //set the score label inital
        scoreLabel = SKLabelNode(text: "Score - 0")
        scoreLabel.zRotation = -1*CGFloat.pi / 2.0
        //TODO: add as ratio of screen rather than hard coded
        scoreLabel.position = CGPoint(x:self.frame.width * 0.85 , y: self.frame.height * 0.90)
    
        //http://iosfonts.com/
        scoreLabel.fontName = "Avenir-BlackOblique"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = UIColor.white
        score = 0
        worldNode.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addrobot), userInfo: nil, repeats: true)
        
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
               // self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
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
    @objc func addrobot () {
        //generates a random element from possible robot array
        possiblerobots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possiblerobots) as! [String]
        
        let robot = SKSpriteNode(imageNamed: possiblerobots[0])
        
        //generates lowest x and y value
        let randomPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomPosition.nextInt())
        
        robot.position = CGPoint(x:position, y:self.frame.size.height + robot.size.height)
        robot.size = CGSize(width: 100, height: 100)
        //sets size of the spawned robot
        robot.physicsBody = SKPhysicsBody(rectangleOf: robot.size)
        //TODO:explore what this means
        robot.physicsBody?.isDynamic = true
        
        //calculates when robot is hit
        robot.physicsBody?.categoryBitMask = robotCategory
        robot.physicsBody?.contactTestBitMask = photonTorpedoCategory
        robot.physicsBody?.collisionBitMask = 0
        
        worldNode.addChild(robot)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -robot.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        robot.run(SKAction.sequence(actionArray))
        
                               
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
        else if gamePause != true{
            
            // Position to rotate towards
            let targetPosition = touch.location(in: self)
            //TODO: MAKE FURTHER ADJUSTMENTS TO do properly
            let torpedoTarget = pointAtDistanceFromPoint(origin: player.position, target: targetPosition, distance: self.frame.height + 100)
            
            //rotate player to where going to shoot
            let angle = atan2(targetPosition.y - player.position.y, targetPosition.x - player.position.x)
            currentRotation = angle + 180
            player.zRotation = currentRotation
            
            
            fireTorpedo(target: torpedoTarget)
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
            } else {
                // Unpause the game
                self.view?.isPaused = false
                gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addrobot), userInfo: nil, repeats: true)
                backgroundMusic.run(SKAction.play())
            }
            
        }
    }
    
    
    
    //
    //collision detected on torpedo
    //
    func fireTorpedo(target:CGPoint) {
        worldNode.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & robotCategory) != 0 {
            torpedoDidCollideWithrobot(torpedoNode: firstBody.node as! SKSpriteNode, robotNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func torpedoDidCollideWithrobot (torpedoNode:SKSpriteNode, robotNode:SKSpriteNode) {
    
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = robotNode.position
        worldNode.addChild(explosion)
        
        worldNode.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        robotNode.removeFromParent()
        
        
        worldNode.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
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
 
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
