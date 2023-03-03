//
//  LevelOneScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//

import SpriteKit

class LevelOneScene: SKScene {
      let gameInitializer = GameInitializer()
      let robotCategory:UInt32 = 0x1 << 1
      let photonTorpedoCategory:UInt32 = 0x1 << 0
      let playerCategory: UInt32 = 0x1 << 2
      let worldNode = SKNode()
    
    var player:SKSpriteNode!

        

    
    override func didMove(to view: SKView) {
            addChild(worldNode)
           

        gameInitializer.initPlayer(playerCategory: playerCategory, robotCategory: robotCategory, worldNode: worldNode, frame: self.frame)
        gameInitializer.initPlayerLives(worldNode: worldNode, frame: self.frame, view:view, playerLives: 3)
        
        gameInitializer.initPauseScreen(sceneNode: self, frame: self.frame)
        player = gameInitializer.getPlayer()
            
        

       }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        guard let touchLocation = touches.first?.location(in: self) else { return }

        let touchedNode = self.atPoint(touchLocation)
        
        guard let touchLocation = touches.first?.location(in: self) else { return }

        if touchedNode.name == "pauseGameButton" {
            gameInitializer.pauseButtonHandler(worldNode: worldNode, view: view!)
            
            
        }
      
       
        
    }
 
    
}
