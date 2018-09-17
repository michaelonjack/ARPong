//
//  Cups.swift
//  ARPong
//
//  Created by Michael Onjack on 9/16/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import ARKit

class Cups: SCNNode {
    
    static func create() -> SCNNode {
        let cupScene = SCNScene(named: "art.scnassets/cups.scn")!
        let cupsNode = cupScene.rootNode.childNode(withName: "cups", recursively: true)!
        
        for i in 1...6 {
            let cupNode = cupsNode.childNode(withName: "cup" + String(i), recursively: true)!
            
            let bodyNode = cupNode.childNode(withName: "body", recursively: true)!
            let brimNode = cupNode.childNode(withName: "brim", recursively: true)!
            let bottomNode = cupNode.childNode(withName: "bottom", recursively: true)!
            
            bodyNode.physicsBody?.categoryBitMask = CollisionCategory.cup.rawValue
            bodyNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
            bodyNode.physicsBody?.contactTestBitMask = CollisionCategory.ball.rawValue
            
            brimNode.physicsBody?.categoryBitMask = CollisionCategory.cup.rawValue
            brimNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
            brimNode.physicsBody?.contactTestBitMask = CollisionCategory.ball.rawValue
            
            bottomNode.physicsBody?.categoryBitMask = CollisionCategory.cup.rawValue
            bottomNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
            bottomNode.physicsBody?.contactTestBitMask = CollisionCategory.ball.rawValue
        }
        
        return cupsNode
    }
}
