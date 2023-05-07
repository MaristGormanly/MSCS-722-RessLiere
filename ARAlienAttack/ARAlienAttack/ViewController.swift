//
//  ViewController.swift
//  ARAlienAttack
//
//  Created by Kyle Ress-Liere on 5/6/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate{
    var planeNode: SCNNode?
    var modelRootB: SCNNode?
    
    @IBOutlet var sceneView: ARSCNView!
    
    var distFromCamera: Double = -5

    
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
        addAlien(index: 0, position: SCNVector3(0, -0.138, distFromCamera))
        addAlien(index: 1, position: SCNVector3(0.13, -0.138, distFromCamera))
        addAlien(index: 2, position: SCNVector3(0.25, -0.138, distFromCamera))
        addAlien(index: 3, position: SCNVector3(0.05, -0.038, distFromCamera))
        addAlien(index: 4, position: SCNVector3(0.16, -0.038, distFromCamera))
        addAlien(index: 5, position: SCNVector3(0.13, 0.062, distFromCamera))
        
        planeNode = SCNNode()
        if let planeNode = planeNode {
            planeNode.name = "Plane"
            planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            planeNode.geometry = SCNBox(width: 0.4, height: 0.015, length: 0.3, chamferRadius: 0)
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "gridDash")
            planeNode.position = SCNVector3(0.125, -0.2, distFromCamera)
            self.sceneView.scene.rootNode.addChildNode(planeNode)
        }
    }
    func addAlien(index: Int, position: SCNVector3) {
        let node = SCNNode()
        node.name = "Node\(index)"
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        // Create material for the front face
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = UIImage(named: "robot")
        frontMaterial.diffuse.wrapS = .clampToBorder
        frontMaterial.diffuse.wrapT = .clampToBorder
        frontMaterial.diffuse.borderColor = UIColor.black // or NSColor.black on macOS
        
        // Create material for the other faces
        let otherMaterial = SCNMaterial()
        otherMaterial.diffuse.contents = UIColor.black
        
        // Assign materials to the SCNBox
        box.materials = [
            frontMaterial,    // front face
            otherMaterial,    // right face
            otherMaterial,    // back face
            otherMaterial,    // left face
            otherMaterial,    // top face
            otherMaterial     // bottom face
        ]
        
        node.geometry = box
        node.position = position
        node.physicsBody?.contactTestBitMask = 1
        self.sceneView.scene.rootNode.addChildNode(node)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // addBallNode()

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
