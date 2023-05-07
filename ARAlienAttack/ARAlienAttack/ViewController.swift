//
//  ViewController.swift
//  ARAlienAttack
//
//  Created by Kyle Ress-Liere on 5/6/23.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    var planeNode: SCNNode?
    var modelRootB: SCNNode?
    
    @IBOutlet var sceneView: ARSCNView!
    var audioPlayer: AVAudioPlayer?

    
    var distFromCamera: Double = -1.5

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
      
    }
    
    func initialSetup() {
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self

        
        addContainer()
        
    }
    func addContainer() {
        guard let backboardScene = SCNScene(named: "art.scnassets/scene.scn") else {
            return
        }
        guard let backBoardNode = backboardScene.rootNode.childNode(withName: "container", recursively: true) else {
            return
        }
        addChildNode()
    }
    /// Add Boxes
    func addChildNode() {
        for i in 0..<10 {
               let xPos = Float.random(in: -0.20...0.20) // Random x position between -0.20 and 0.20
               let yPos = Float.random(in: -0.10...0.10) // Random y position between -0.10 and 0.10
               
               let position = SCNVector3(xPos, yPos, Float(distFromCamera))
               addAlien(index: i, position: position)
           }
//        planeNode = SCNNode()
//        if let planeNode = planeNode {
//            planeNode.name = "Plane"
//            planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//            planeNode.geometry = SCNBox(width: 0.4, height: 0.015, length: 0.3, chamferRadius: 0)
//            planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "gridDash")
//            planeNode.position = SCNVector3(0.125, -0.2, distFromCamera)
//            self.sceneView.scene.rootNode.addChildNode(planeNode)
//        }
    }
    func addAlien(index: Int, position: SCNVector3) {
        let node = SCNNode()
        node.name = "Node\(index)"
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil) // Change to .dynamic
        let sphere = SCNSphere(radius: 0.05) // Adjust the radius as needed
            
        // Create material for the front face
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = UIImage(named: "robot")
        frontMaterial.diffuse.wrapS = .clampToBorder
        frontMaterial.diffuse.wrapT = .clampToBorder
        frontMaterial.diffuse.borderColor = UIColor.black // or NSColor.black on macOS

        // Create material for the other faces
        let otherMaterial = SCNMaterial()
        otherMaterial.diffuse.contents = UIColor.black
            
        // Assign materials to the SCNSphere
        sphere.materials = [
            frontMaterial,    // front face
            otherMaterial,    // right face
            otherMaterial,    // back face
            otherMaterial,    // left face
            otherMaterial,    // top face
            otherMaterial     // bottom face
        ]
            
        node.geometry = sphere
        node.position = position
        node.physicsBody?.contactTestBitMask = 1
        node.physicsBody?.collisionBitMask = 2 // Add collision bit mask so aliens can collide with each other

        self.sceneView.scene.rootNode.addChildNode(node)
            
        // Add floating animation
        let floatUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1)
        let floatDown = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1)
        let floatSequence = SCNAction.sequence([floatUp, floatDown])
        let repeatFloating = SCNAction.repeatForever(floatSequence)
        node.runAction(repeatFloating)
        
        // Set a random velocity for the aliens
        let randomVelocityX = CGFloat.random(in: -1.0...1.0)
        let randomVelocityY = CGFloat.random(in: -1.0...1.0)
        let randomVelocityZ = CGFloat.random(in: -1.0...1.0)
        node.physicsBody?.velocity = SCNVector3(randomVelocityX, randomVelocityY, randomVelocityZ)
    }

    
    func playExplosionSound() {
        guard let url = Bundle.main.url(forResource: "explosion", withExtension: "mp3") else {
            print("Failed to find explosion.mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play explosion sound: \(error.localizedDescription)")
        }
    }
    func playLaserSound() {
        guard let url = Bundle.main.url(forResource: "torpedo", withExtension: "mp3") else {
            print("Failed to find explosion.mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play explosion sound: \(error.localizedDescription)")
        }
    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    func fireLaser() {
        // Handle the shooting
        guard let frame = sceneView.session.currentFrame else {
            return
        }
        let camMatrix = SCNMatrix4(frame.camera.transform)
        let direction = SCNVector3Make(-camMatrix.m31 * 5.0, -camMatrix.m32 * 5.0, -camMatrix.m33 * 5.0) // Reduced Y component force
        let position = SCNVector3Make(camMatrix.m41, camMatrix.m42, camMatrix.m43)
        
        // Create a SCNBox for laser
        let laser = SCNBox(width: 0.05, height: 0.05, length: 0.2, chamferRadius: 0.05)
        laser.firstMaterial?.diffuse.contents = UIImage(named: "greenTexture")
        laser.firstMaterial?.emission.contents = UIImage(named: "greenTexture")
        
        // Create laser node using laser SCNBox
        let laserNode = SCNNode(geometry: laser)
        laserNode.name = "laser"
        laserNode.position = position
        laserNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        laserNode.physicsBody?.categoryBitMask = 3
        laserNode.physicsBody?.contactTestBitMask = 1
        sceneView.scene.rootNode.addChildNode(laserNode)
        laserNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 10.0), SCNAction.removeFromParentNode()]))
        
        // Calculate velocity add apply force to laser
        let velocityInLocalSpace = SCNVector3(0, 0, -0.15)
        let velocityInWorldSpace = laserNode.presentation.convertVector(velocityInLocalSpace, to: nil)
        laserNode.physicsBody?.velocity = velocityInWorldSpace
        laserNode.physicsBody?.applyForce(direction, asImpulse: true)
        playLaserSound()

    }
    //print upon collision
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let firstNode = contact.nodeA
        let secondNode = contact.nodeB
        
        var alienNode: SCNNode?
        var laserNode: SCNNode?
        
        if firstNode.name == "laser" && secondNode.name?.hasPrefix("Node") == true {
            alienNode = secondNode
            laserNode = firstNode
        } else if secondNode.name == "laser" && firstNode.name?.hasPrefix("Node") == true {
            alienNode = firstNode
            laserNode = secondNode
        }
        
        if let alienNode = alienNode {
            print("Alien hit: \(alienNode.name ?? "Unknown")")
            alienNode.removeFromParentNode() // Remove the alien node from the scene
            laserNode?.removeFromParentNode() // Remove the laser node from the scene (optional)
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       fireLaser()

    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) { }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
