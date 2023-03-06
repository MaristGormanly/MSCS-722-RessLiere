
import SpriteKit
class ConfirmationNode: SKNode {
    let messageLabel: SKLabelNode
    let yesButton: SKSpriteNode
    let noButton: SKSpriteNode
    
    init(message: String) {
        // Create message label
        messageLabel = SKLabelNode(text: message)
        messageLabel.fontSize = 20
        messageLabel.fontColor = .white
        messageLabel.position = CGPoint(x: 0, y: 50)
        
        // Create "Yes" button
        let yesTexture = SKTexture(imageNamed: "yes_button")
        yesButton = SKSpriteNode(texture: yesTexture)
        yesButton.position = CGPoint(x: -50, y: -50)
        yesButton.name = "yesButton"
        
        // Create "No" button
        let noTexture = SKTexture(imageNamed: "no_button")
        noButton = SKSpriteNode(texture: noTexture)
        noButton.position = CGPoint(x: 50, y: -50)
        noButton.name = "noButton"
        
        super.init()
        
        // Add nodes to parent
        addChild(messageLabel)
        addChild(yesButton)
        addChild(noButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

