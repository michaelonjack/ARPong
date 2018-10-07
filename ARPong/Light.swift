//
//  Light.swift
//  ARPong
//
//  Created by Michael Onjack on 9/22/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import SceneKit

class Light:SCNNode {
    static func create() -> SCNNode {
        let light = SCNLight()
        light.type = .omni
        light.intensity = 0
        light.temperature = 0
        
        let lightNode = SCNNode()
        lightNode.light = light
        // set the light node object’s y position to one meter above its parent node
        lightNode.position = SCNVector3(0,2,0)
        
        return lightNode
    }
}
