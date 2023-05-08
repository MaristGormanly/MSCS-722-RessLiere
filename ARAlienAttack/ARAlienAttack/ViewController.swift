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
    let numberOfAliens = 10
    var shotsRemaining: Int = 9999
    var aliensDestroyed = 0



    ///////////////////////////////////////////////////////////////////
    //     SETUP FUNCTIONS          /
    //////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuScreen()

        shotsRemaining = numberOfAliens
        initialSetup()

        view.addSubview(shotsRemainingLabel)
        view.addSubview(aliensRemainingLabel)
        shotsRemainingLabel.font = UIFont(name: "Copperplate", size: 18)
        aliensRemainingLabel.font = UIFont(name: "Copperplate", size: 18)

        NSLayoutConstraint.activate([
            shotsRemainingLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            shotsRemainingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            aliensRemainingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aliensRemainingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.08 - aliensRemainingLabel.frame.height / 2)
        ])

       updateShotsRemainingLabel()
        updateAliensRemainingLabel()

    }

    
    func initialSetup() {
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self

    }
    ///////////////////////////////////////////////////////////////////
    //     END SETUP             /
    //////////////////////////////////////////////////////////////////
   
    
    ///////////////////////////////////////////////////////////////
    //MAIN MENU AND GAME STARTUP//
    ///////////////////////////////////////////////////////////////
    
    func setupMenuScreen() {
        let playButton = UIButton(type: .custom)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let originalImage = UIImage(named: "start-game") { // Replace "start-game" with the name of your image file
            let newSize = CGSize(width: originalImage.size.width * 0.65, height: originalImage.size.height * 0.65)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            originalImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let resizedImage = resizedImage {
                playButton.setImage(resizedImage, for: .normal)
            } else {
                playButton.setImage(originalImage, for: .normal)
            }
        }
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])

    }


    @objc func playButtonTapped(_ sender: UIButton) {
        sender.removeFromSuperview() // Remove the button from the view
            //starts adding game elements
        startGame()

        view.addSubview(shotsRemainingLabel)
        NSLayoutConstraint.activate([
            shotsRemainingLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            shotsRemainingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        updateShotsRemainingLabel()
    }
    
    func returnToMainMenu() {
        aliensDestroyed = 0
        shotsRemaining = numberOfAliens
        updateShotsRemainingLabel()

        // Reset aliens remaining and hide the label
        updateAliensRemainingLabel()
        aliensRemainingLabel.removeFromSuperview()

        // Remove all existing alien nodes
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name?.hasPrefix("Node") == true {
                node.removeFromParentNode()
            }
        }
        
        // Remove shotsRemainingLabel
        shotsRemainingLabel.removeFromSuperview()

        // Show main menu
        setupMenuScreen()
    }


    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartGame()
        }
        let mainMenuAction = UIAlertAction(title: "Main Menu", style: .default) { _ in
            self.returnToMainMenu()
        }
        alertController.addAction(restartAction)
        alertController.addAction(mainMenuAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }


    ///////////////////////////////////////////////////////////////////
    //     GAME INIT               /
    //////////////////////////////////////////////////////////////////
    func startGame() {
        guard let backboardScene = SCNScene(named: "art.scnassets/scene.scn") else {
            return
        }
        guard let backBoardNode = backboardScene.rootNode.childNode(withName: "container", recursively: true) else {
            return
        }
        shotsRemaining = numberOfAliens * 2
        
        spawnAliens()
    }
    func spawnAliens() {
        let minDistance: Float = 0.03
        var spawnedPositions: [SCNVector3] = []
        
        for i in 0..<numberOfAliens {
            var position: SCNVector3
            
            repeat {
                let xPos = Float.random(in: -0.50...0.50) // Random x position between -0.20 and 0.20
                let yPos = Float.random(in: -0.30...0.30) // Random y position between -0.10 and 0.10
                
                position = SCNVector3(xPos, yPos, Float(distFromCamera))
            } while !spawnedPositions.isEmpty && spawnedPositions.contains(where: { distanceBetween($0, position) < minDistance })
            
            spawnedPositions.append(position)
            addAlien(index: i, position: position)
        }
    }

    func addAlien(index: Int, position: SCNVector3) {
        let node = SCNNode()
        node.name = "Node\(index)"
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        let sphere = SCNSphere(radius: 0.1) // Adjust the radius as needed
        
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
        setupAlienPhysics(node: node)

        self.sceneView.scene.rootNode.addChildNode(node)
        

        
        // Add floating animation
        let floatUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1)
        let floatDown = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1)
        let floatSequence = SCNAction.sequence([floatUp, floatDown])
        let repeatFloating = SCNAction.repeatForever(floatSequence)
        node.runAction(repeatFloating)
        
        node.runAction(randomWanderAnimation())

    }
    
    func setupAlienPhysics(node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: node.geometry!, options: nil))
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.collisionBitMask = 1
        node.physicsBody?.contactTestBitMask = 1
        // Set a lower restitution value for less bounciness
        node.physicsBody?.restitution = 0.00000000000001
    }

    func randomWanderAnimation() -> SCNAction {
        let moveDuration = TimeInterval.random(in: 1...5)
        
        let moveAction: SCNAction
        if let camera = self.sceneView.pointOfView {
            // Calculate a random position within the camera's field of view
            let position = SCNVector3(
                x: Float.random(in: -0.8...0.8),
                y: Float.random(in: -0.8...0.8),
                z: Float(distFromCamera)
            )
            
            // Check if the position is within the camera's frustum
            let projectedPosition = sceneView.projectPoint(position)
            let viewport = sceneView.bounds
            let isInView = viewport.contains(CGPoint(x: CGFloat(projectedPosition.x), y: CGFloat(projectedPosition.y)))
            if isInView {
                // Apply move action only if the position is within the camera's view
                moveAction = SCNAction.move(to: position, duration: moveDuration)
            } else {
                // If the position is outside of the camera's view, create a new move action
                moveAction = randomWanderAnimation()
            }
        } else {
            // If the camera is not available, create a move action to a random position
            let xPos = CGFloat.random(in: -0.70...0.70)
            let yPos = CGFloat.random(in: -0.70...0.70)
            let position = SCNVector3(xPos, yPos, 0)
            moveAction = SCNAction.move(to: position, duration: moveDuration)
        }
        
        let reverseMoveAction = moveAction.reversed()
        let sequence = SCNAction.sequence([moveAction, reverseMoveAction])
        let repeatSequence = SCNAction.repeatForever(sequence)
        return repeatSequence
    }


    ///////////////////////////////////////////////////////////////////
    //     END GAME INIT               /
    //////////////////////////////////////////////////////////////////
    
    
    ///////////////////////////////////////////////////////////////////
    //     GAME LOGIC            /
    //////////////////////////////////////////////////////////////////
    func fireLaser() {
        if shotsRemaining <= 0 {
               return
           }
           
           shotsRemaining -= 1
           updateShotsRemainingLabel()
           
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
        checkGameOver()

    }
    lazy var shotsRemainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    lazy var aliensRemainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()


    func updateShotsRemainingLabel() {
        shotsRemainingLabel.text = "Shots Remaining: \(shotsRemaining)"
    }
    func updateAliensRemainingLabel() {
        DispatchQueue.main.async {
            let aliensRemaining = self.numberOfAliens - self.aliensDestroyed
            self.aliensRemainingLabel.text = "Aliens Remaining: \(aliensRemaining)"
        }
    }

    
    var destroyedAliens = Set<SCNNode>()

    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        var alienNode: SCNNode?
        var laserNode: SCNNode?
        let firstNode = contact.nodeA
        let secondNode = contact.nodeB

        if firstNode.physicsBody?.categoryBitMask == 3 && secondNode.physicsBody?.contactTestBitMask == 1 {
            alienNode = secondNode
            laserNode = firstNode
        } else if secondNode.physicsBody?.categoryBitMask == 3 && firstNode.physicsBody?.contactTestBitMask == 1 {
            alienNode = firstNode
            laserNode = secondNode
        }

        if let alienNode = alienNode, !destroyedAliens.contains(alienNode) {
            print("Alien hit: \(alienNode.name ?? "Unknown")")
            destroyedAliens.insert(alienNode)
            alienNode.removeFromParentNode() // Remove the alien node from the scene
            laserNode?.removeFromParentNode() // Remove the laser node from the scene (optional)
            aliensDestroyed += 1
            playExplosionSound() // Play explosion sound
            updateAliensRemainingLabel()
        }

        checkGameOver()
    }

    
    func checkGameOver() {
        if aliensDestroyed == numberOfAliens {
            showAlert(title: "Success!", message: "All robots have been destroyed!")
        } else if shotsRemaining == 0 && aliensDestroyed < numberOfAliens {
            showAlert(title: "Game Over", message: "You couldn't destroy all the robots.")
            
        }
    }

    func restartGame() {
        aliensDestroyed = 0
        shotsRemaining = numberOfAliens
        updateShotsRemainingLabel()
        
        // Remove all existing alien nodes
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name?.hasPrefix("Node") == true {
                node.removeFromParentNode()
            }
        }
        updateAliensRemainingLabel()
        spawnAliens()
    }

 
    ///////////////////////////////////////////////////////////////////
    //     endGAME LOGIC            /
    //////////////////////////////////////////////////////////////////
  
  
    /////////////////////////////////////////////////////////////////
    //AUDIO HANDLERS          ////
    ///////////////////////////////////////////////////////////////
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
    func distanceBetween(_ pos1: SCNVector3, _ pos2: SCNVector3) -> Float {
        let xDist = pos1.x - pos2.x
        let yDist = pos1.y - pos2.y
        let zDist = pos1.z - pos2.z
        
        return sqrt(xDist * xDist + yDist * yDist + zDist * zDist)
    }

    ///////////////////////////////////////////////////////////////
    //OVERIDE and setup functions //
    ///////////////////////////////////////////////////////////////
    ///
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       fireLaser()

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
