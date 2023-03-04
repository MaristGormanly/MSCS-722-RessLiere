//
//  LeaderboardScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/4/23.
//

import SpriteKit

class LeaderboardScene: SKScene {
    var returnHomeButton:SKSpriteNode!
    var leadboardLabel:SKLabelNode!
    let highScoresKey = "highScores"

    override func didMove(to view: SKView) {
        
        let titleColor = UIColor(red: 0.79, green: 0.85, blue: 0.32, alpha: 1.0)
        
        leadboardLabel = SKLabelNode(text: "Leaderboard: ")
        leadboardLabel.zRotation = -1*CGFloat.pi / 2.0
        
        leadboardLabel.position = CGPoint(x:self.frame.width * 0.86 , y: self.frame.height / 2)
        
        leadboardLabel.fontName = "Copperplate"
        leadboardLabel.fontSize = 72
        leadboardLabel.fontColor = titleColor
        addChild(leadboardLabel)
        
        returnHomeButton = SKSpriteNode(imageNamed:"return-home")
        returnHomeButton.position = CGPoint(x:self.frame.size.width * 0.18, y: self.frame.height * 0.08)
        returnHomeButton.setScale(0.75)
        returnHomeButton.zRotation = -1*CGFloat.pi / 2.0
        returnHomeButton.name = "returnHomeButton"
        addChild(returnHomeButton)
        
        var highScores = UserDefaults.standard.array(forKey: highScoresKey) as? [Int] ?? []
        
        var yPosition = leadboardLabel.position.x - leadboardLabel.frame.size.width/2 + 30 // start position below leaderboard label
        
        for (index, score) in highScores.enumerated() {
            let scoreLabel = SKLabelNode(text: "Score \(index+1): \(score)")
            if(index == 0){
                scoreLabel.position = CGPoint(x:yPosition - scoreLabel.frame.size.height/2 - 30  , y: self.frame.width * 0.86)

                 scoreLabel.text = ("HIGH SCORE \(index+1): \(score)")
                scoreLabel.zRotation = -1*CGFloat.pi / 2.0
                scoreLabel.fontName = "Copperplate"
                scoreLabel.fontSize = 36
                scoreLabel.fontColor = titleColor
                addChild(scoreLabel)
            }
            else{
                
                scoreLabel.zRotation = -1*CGFloat.pi / 2.0
                scoreLabel.position = CGPoint(x:yPosition - scoreLabel.frame.size.height/2 + 30 , y: self.frame.width * 0.86)
                scoreLabel.fontName = "Copperplate"
                scoreLabel.fontSize = 36
                scoreLabel.fontColor = UIColor.white
                addChild(scoreLabel)
            }
            // Update the Y position for the next label
            yPosition = scoreLabel.position.x - scoreLabel.frame.size.width/2
        }
    
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if(nodesArray.first?.name == "returnHomeButton" ){
            let gameScene = GameScene(fileNamed: "HomeScene")
                            gameScene?.scaleMode = .aspectFill
                            self.scene?.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
}
