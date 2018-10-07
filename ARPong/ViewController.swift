//
//  ViewController.swift
//  ARPong
//
//  Created by Michael Onjack on 9/16/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var forceSlider: UISlider!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var cupsNode:SCNNode = Cups.create()
    private var ballNode:SCNNode = Ball.create()
    private var floorNode:SCNNode = Floor.create()
    private var nodesAdded:Bool = false
    private var planeNodes:[SCNNode] = []
    private var lightNodes:[SCNNode] = []
    private var cameraTransform: matrix_float4x4? {
        let camera = sceneView.session.currentFrame?.camera
        return camera?.transform
    }
    private var score = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = String(self.score)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "0"
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [.showPhysicsShapes, .showPhysicsFields]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    ///
    /// Handles a user's tap on the AR Scene View
    ///
    /// Processed tap locations:
    /// - Ball node: Ball is tossed
    /// - Plane node: Scene nodes (ball, cups, floor) are placed on top of the plane node
    ///
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        // Get tap location
        let tapLocation = sender.location(in: sceneView)
        
        // Perform hit test
        let results = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.categoryBitMask: CollisionCategory.ball.rawValue | CollisionCategory.plane.rawValue])
        
        if let result = results.first {
            
            // Ball was tapped so toss
            if result.node == self.ballNode {
                tossBall()
            }
            
            else if self.planeNodes.contains(result.node) {
                guard let planeAnchor = sceneView.anchor(for: result.node) as? ARPlaneAnchor else {return}
                
                addSceneNodes(toPlaneAnchor: planeAnchor)
            }
        }
    }
    
    
    ///
    /// Tosses the ball node by applying a force to the node's physics body
    ///
    func tossBall() {
        if let cameraTransform = cameraTransform {
            
            // Create a force with a magnitude given by the slider in the direction of the camera
            let force = simd_make_float4(0, 0, -(forceSlider.value), 0)
            let rotatedForce = simd_mul(cameraTransform, force)
            let vectorForce = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
            
            ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: ballNode.geometry!, options: nil))
            
            // Define what type of nodes the ball can collide with
            ballNode.physicsBody?.categoryBitMask = CollisionCategory.ball.rawValue
            ballNode.physicsBody?.collisionBitMask = CollisionCategory.cup.rawValue | CollisionCategory.ball.rawValue | CollisionCategory.floor.rawValue
            ballNode.physicsBody?.contactTestBitMask = CollisionCategory.cup.rawValue | CollisionCategory.ball.rawValue | CollisionCategory.floor.rawValue
            
            ballNode.physicsBody?.applyForce(vectorForce, asImpulse: true)
        }
    }
    
    
    
    ///
    /// Adds the basic nodes to the scene (cups, ball, floor) using the parameter plane anchor's position.
    ///
    /// - Parameter planeAnchor: The plane anchor the nodes will be added to
    ///
    func addSceneNodes(toPlaneAnchor planeAnchor: ARPlaneAnchor) {
        
        floorNode.removeFromParentNode()
        cupsNode.removeFromParentNode()
        ballNode.removeFromParentNode()
        
        // Position the floor node and add to the scene
        floorNode.simdTransform = planeAnchor.transform
        sceneView.scene.rootNode.addChildNode(floorNode)
        
        // Position the cups and add to the scene
        cupsNode.position = SCNVector3(floorNode.position.x, floorNode.position.y + 0.085, floorNode.position.z)
        sceneView.scene.rootNode.addChildNode(cupsNode)
        
        // The cups have been added, let's add the ball to the scene
        if let cameraTransform = cameraTransform {
            var translation = matrix_identity_float4x4
            translation.columns.3.x = 0
            translation.columns.3.y = 0
            translation.columns.3.z = -0.3
            ballNode.simdTransform = matrix_multiply(cameraTransform, translation)
            
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
        
        self.nodesAdded = true
        
    }
    
    
    
    ///
    /// Repositions the ball using the frame's current positioning
    ///
    @IBAction func resetPressed(_ sender: Any) {
        if let cameraTransform = cameraTransform {
            ballNode.physicsBody = .none
            
            var translation = matrix_identity_float4x4
            translation.columns.3.x = 0
            translation.columns.3.y = 0
            translation.columns.3.z = -0.4
            ballNode.simdTransform = matrix_multiply(cameraTransform, translation)
            
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
    }
    
    
    
    func addLightNodeTo(_ node:SCNNode) {
        let lightNode = Light.create()
        node.addChildNode(lightNode)
        lightNodes.append(lightNode)
    }
}




extension ViewController: ARSCNViewDelegate {
    
    ///
    /// Called when a node is added to a scene's anchor
    ///
    /// For our purposes, this function will be called when a plane node is automatically added to detected anchors
    ///
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Set the properties of the plane node
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.categoryBitMask = CollisionCategory.plane.rawValue
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -.pi/2
        
        self.planeNodes.append(planeNode)
        node.addChildNode(planeNode)
        
        
    }
    
    
    
    ///
    /// Called exactly once per frame in SceneKit before any animation, action evaluation, or physics simulationx
    ///
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate else {return}
        
        DispatchQueue.main.async {
            for lightNode in self.lightNodes {
                guard let light = lightNode.light else {return}
                
                light.intensity = lightEstimate.ambientIntensity
                light.temperature = lightEstimate.ambientColorTemperature
            }
        }
    }
}




extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        return
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        return
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        /*
        let cap = hatNode?.childNode(withName: "cap", recursively: true)
        
        if( (contact.nodeA == ballNode && contact.nodeB == cap) || (contact.nodeA == cap && contact.nodeB == ballNode) ) {
            resetPressed(ballNode)
            score = score + 1
        }
 */
    }
}



