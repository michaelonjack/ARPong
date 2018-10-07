//
//  Ball.swift
//  ARPong
//
//  Created by Michael Onjack on 9/16/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import SceneKit

class Ball:SCNNode {
    static func create() -> SCNNode {
        let ballGeometry = SCNSphere(radius: 0.04)
        let ballNode = SCNNode(geometry: ballGeometry)
        ballNode.categoryBitMask = CollisionCategory.ball.rawValue
        
        return ballNode
    }
}
