//
//  ViewController.swift
//  ARAlienAttack
//
//  Created by Kyle Ress-Liere on 5/6/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var planeNode: SCNNode?
    var modelRootB: SCNNode?
    
    @IBOutlet var sceneView: ARSCNView!
    
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
        addBoxNodes(index: 0, position: SCNVector3(0, -0.138, -0.3))
        addBoxNodes(index: 1, position: SCNVector3(0.12, -0.138, -0.3))
        addBoxNodes(index: 2, position: SCNVector3(0.24, -0.138, -0.3))
        addBoxNodes(index: 3, position: SCNVector3(0.06, -0.038, -0.3))
        addBoxNodes(index: 4, position: SCNVector3(0.18, -0.038, -0.3))
        addBoxNodes(index: 5, position: SCNVector3(0.12, 0.062, -0.3))
        
        planeNode = SCNNode()
        if let planeNode = planeNode {
            planeNode.name = "Plane"
            planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            planeNode.geometry = SCNBox(width: 0.4, height: 0.015, length: 0.3, chamferRadius: 0)
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "gridDash")
            planeNode.position = SCNVector3(0.125, -0.2, -0.28)
            self.sceneView.scene.rootNode.addChildNode(planeNode)
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
