import UIKit
import SpriteKit

public func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
public func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    public func normalized() -> CGPoint {
        return self / length()
    }
}

public func pointAtDistanceFromPoint(origin: CGPoint, target:CGPoint, distance: CGFloat) -> CGPoint {
    let x1 = origin.x
    let y1 = origin.y
    
    let x2 = target.x
    let y2 = target.y
    
    let slope = (y2 - y1) / (x2 - x1)
    
    let x3 = x1 + sqrt(pow(distance, 2) / (1 + pow(slope, 2)))
    let y3 = y1 + slope * (x2 - x1)
    
    return CGPoint(x: x3, y: y3)
}

public func pointAlongLine(from start: CGPoint, to end: CGPoint, at distance: CGFloat) -> CGPoint {
    // Calculate the vector from start to end
    let vector = CGVector(dx: end.x - start.x, dy: end.y - start.y)
    
    // Normalize the vector
    let unitVector = CGVector(dx: vector.dx / vector.length(), dy: vector.dy / vector.length())
    
    // Calculate the new point along the line at the specified distance
    let newX = start.x + (unitVector.dx * distance)
    let newY = start.y + (unitVector.dy * distance)
    
    return CGPoint(x: newX, y: newY)
}

func completeLevel(index: Int) {
    if var completedLevels = UserDefaults.standard.array(forKey: "completedLevels") as? [Bool] {
        // Set the corresponding index in completedLevels to true
        if index < completedLevels.count {
            completedLevels[index] = true
            // Save the updated completedLevels array to UserDefaults
            UserDefaults.standard.set(completedLevels, forKey: "completedLevels")
        }
    }
}

func clearAudio(scene: [SKNode]){
    for child in scene {
        // Check if the child is an SKAudioNode
        if let audioNode = child as? SKAudioNode {
            // Remove the audio node from the scene
            audioNode.removeFromParent()
        }
    }
}


extension CGVector {
    public func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
}

