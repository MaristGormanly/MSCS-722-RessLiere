//
//  ScoreInitializer.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 3/2/23.
//

import SpriteKit

class ScoreInitializer {
    
    static func initScoreLabel(in scene: SKScene) {
        let scoreLabel = SKLabelNode(text: "Score - 0")
        scoreLabel.zRotation = -1*CGFloat.pi / 2.0
        scoreLabel.position = CGPoint(x: scene.frame.width * 0.85, y: scene.frame.height / 2)
        scoreLabel.fontName = "Avenir-BlackOblique"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = UIColor.white
        scene.addChild(scoreLabel)
    }
}
