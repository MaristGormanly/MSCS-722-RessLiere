//
//  HomeScene.swift
//  NierMobile
//
//  Created by Kyle Ress-Liere on 2/26/23.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation


class HomeScene: SKScene {
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("testing")
        let transition = SKTransition.moveIn(with: .right, duration: 1)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene,transition: transition)
       
    }
}


