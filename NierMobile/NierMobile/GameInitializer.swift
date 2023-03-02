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
    
    
}
