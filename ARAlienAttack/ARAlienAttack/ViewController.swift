import UIKit
import SceneKit
import ARKit
import AVFoundation

extension SCNVector3 {
    func multipliedBy(scalar: Float) -> SCNVector3 {
        return SCNVector3(x * scalar, y * scalar, z * scalar)
    }
}

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
        node.physicsBody?.collisionBitMask = 2 // Add collision bit mask so aliens can collide witheach other
        sceneView.scene.rootNode.addChildNode(node)
        }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        
        if let modelRootB = modelRootB {
            let direction = currentPositionOfCamera - modelRootB.position
            let adjustedDirection = direction.multipliedBy(scalar: 0.01)
            modelRootB.physicsBody?.applyForce(adjustedDirection, asImpulse: true)
        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "Node0" || contact.nodeB.name == "Node0" {
            print("Node0 collided")
        }
        // Add any other collision handling code here
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}


