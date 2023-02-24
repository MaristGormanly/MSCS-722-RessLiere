//
//  GameScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/23/23.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //PROPTERTIES
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
    var possibleAliens = ["alien","alien2","alien3"]
    
    //TODO: bitwise defines each alien and projectile
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    //motion mangaer
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    //music
    var backgroundMusic: SKAudioNode!
    
    //
    //
    //
    override func didMove(to view: SKView) {
        
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
        self.addChild(starfield)
        //send starfield to back of screen
        starfield.zPosition = -1
        
        //create a player
        player = SKSpriteNode(imageNamed: "spaceship2")
        player.setScale(0.2)
        
       
        //set player intial postiion
        player.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.height * 0.08)
        
        //add player to screen
        self.addChild(player)
        
        //set physics for scene zero gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //sets physics rules for contact
        //TODO: contact delegate will be defined
        self.physicsWorld.contactDelegate = self
        
        
        
        //set the score label inital
        scoreLabel = SKLabelNode(text: "Score - 0")
        //TODO: add as ratio of screen rather than hard coded
        scoreLabel.position = CGPoint(x:self.frame.width / 2, y: self.frame.height * 0.90)
    
        //http://iosfonts.com/
        scoreLabel.fontName = "Avenir-BlackOblique"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
               // self.yAcceleration = CGFloat(acceleration.y) * 0.75 + self.yAcceleration * 0.25
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
    @objc func addAlien () {
        //generates a random element from possible alien array
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        //generates lowest x and y value
        let randomPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomPosition.nextInt())
        
        alien.position = CGPoint(x:position, y:self.frame.size.height + alien.size.height)
        
        //sets size of the spawned alien
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        //TODO:explore what this means
        alien.physicsBody?.isDynamic = true
        
        //calculates when alien is hit
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
                               
    }
    
    
    //
    //when screen touched missile is fired
    //
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    
    
    //
    //collision detected on torpedo
    //
    func fireTorpedo() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
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
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
    
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) {
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
        
       
    }
 
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
