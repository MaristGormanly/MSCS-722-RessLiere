//
//  GameInitializer.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//


import SpriteKit
    
class GameInitializer {
    //player
    var playerA:SKSpriteNode!
    var playerLivesList: [SKSpriteNode] = []
    
    var pauseGameButton:SKSpriteNode!
    var quitGameButton:SKSpriteNode!
    
    //pause toggle
    var gamePaused = false
    
    
    
    func getPlayer() -> SKSpriteNode {
           return playerA
       }
    
    func initPlayer(playerCategory:UInt32, robotCategory:UInt32,worldNode:SKNode,frame:CGRect){
        //create a player
        playerA = SKSpriteNode(imageNamed: "spaceship2")
        playerA.setScale(0.1)
       
        //player physics body
        playerA.physicsBody = SKPhysicsBody(circleOfRadius: playerA.size.width/3)
        playerA.physicsBody?.categoryBitMask = playerCategory
        playerA.physicsBody?.contactTestBitMask = robotCategory
        playerA.physicsBody?.collisionBitMask = 0
        playerA.physicsBody?.affectedByGravity = false
        playerA.zRotation = -1*CGFloat.pi / 2.0

        
        //set player intial postiion
        playerA.position =  CGPoint(x: frame.size.width * 0.08, y: frame.height / 2)

        //add player to screen
        worldNode.addChild(playerA)
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
    
}
