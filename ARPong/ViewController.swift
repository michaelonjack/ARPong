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
    
    private var cupsNode:SCNNode? = nil
    private var ballNode:SCNNode? = nil
    private var floorNode:SCNNode? = nil
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

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        // Get tap location
        let tapLocation = sender.location(in: sceneView)
        
        // Perform hit test
        let results = sceneView.hitTest(tapLocation, options: nil)
        
        if let result = results.first {
            // Ball was tapped so toss
            if result.node == self.ballNode {
                tossBall()
            }
        }
    }
    
    func tossBall() {
        if let ballNode = ballNode, let cameraTransform = cameraTransform {
            
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
    
    @IBAction func resetPressed(_ sender: Any) {
        if let cameraTransform = cameraTransform, let ballNode = ballNode {
            ballNode.physicsBody = .none
            
            var translation = matrix_identity_float4x4
            translation.columns.3.x = 0
            translation.columns.3.y = 0
            translation.columns.3.z = -0.4
            ballNode.simdTransform = matrix_multiply(cameraTransform, translation)
            
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
    }
}




extension ViewController: ARSCNViewDelegate {
    
    // A node has need added to the detected plane anchor, let's add stuff to it!
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        
        if floorNode == nil {
            floorNode = Floor.create(forAnchor: planeAnchor)
            floorNode!.simdTransform = planeAnchor.transform
            
            sceneView.scene.rootNode.addChildNode(floorNode!)
        }
        
        if cupsNode == nil {
            cupsNode = Cups.create()
            let x = planeAnchor.center.x
            let y = planeAnchor.center.y + 0.1
            let z = planeAnchor.center.z
            cupsNode!.position = SCNVector3(x,y,z)
            node.addChildNode(cupsNode!)
        }
        
        // The cups has been added, let's add the ball
        if ballNode == nil {
            
            ballNode = Ball.create()
            
            if let cameraTransform = cameraTransform {
                var translation = matrix_identity_float4x4
                translation.columns.3.x = 0
                translation.columns.3.y = 0
                translation.columns.3.z = -0.3
                ballNode!.simdTransform = matrix_multiply(cameraTransform, translation)
                
                sceneView.scene.rootNode.addChildNode(ballNode!)
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



