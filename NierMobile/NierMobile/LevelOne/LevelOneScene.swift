//
//  LevelOneScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//

import SpriteKit

class LevelOneScene: SKScene {
      let game = GameInitializer()
      let robotCategory:UInt32 = 0x1 << 1
      let photonTorpedoCategory:UInt32 = 0x1 << 0
      let playerCategory: UInt32 = 0x1 << 2
      let worldNode = SKNode()
    
    var player:SKSpriteNode!

        

    
    override func didMove(to view: SKView) {
            addChild(worldNode)
           

        game.initPlayer(playerCategory: playerCategory, robotCategory: robotCategory, worldNode: worldNode, frame: self.frame)
        game.initPlayerLives(worldNode: worldNode, frame: self.frame, view:view, playerLives: 3)
        game.initStarfield(worldNode: worldNode, frame: self.frame)
        game.playMusic(worldNode: worldNode)
        game.initPauseScreen(sceneNode: self, frame: self.frame)
        player = game.getPlayer()
        game.handleMotion()
        //set physics

        

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
