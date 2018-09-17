//
//  Floor.swift
//  ARPong
//
//  Created by Michael Onjack on 9/16/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import ARKit

class Floor:SCNNode {
    static func create(forAnchor planeAnchor:ARPlaneAnchor) -> SCNNode {
        
        let cupsScene = SCNScene(named: "art.scnassets/cups.scn")!
        let floorNode = cupsScene.rootNode.childNode(withName: "floor", recursively: true)!
        
        floorNode.physicsBody?.categoryBitMask = CollisionCategory.floor.rawValue
        floorNode.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue
        floorNode.physicsBody?.contactTestBitMask = CollisionCategory.ball.rawValue
        
        return floorNode
    }
}
