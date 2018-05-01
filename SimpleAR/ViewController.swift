//
//  ViewController.swift
//  SimpleAR
//
//  Created by Joseph Ugowe on 4/28/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBox()
        self.addTapGestureToSceneView()
        self.configureLighting()
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
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.blue
//        let donut = SCNTorus(ringRadius: 0.05, pipeRadius: 0.025)
//        donut.firstMaterial?.diffuse.contents = UIColor.purple
        
        // A node represents the position and the coordinates of an object in a 3D space.
        // By itself, the node has no visible content.
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        boxNode.castsShadow = true
        
        // Create an instance of the SceneKit scene to be displayed in the view
        let scene = SCNScene()
        // A root node in a scene that defines the coordinate system of the real world rendered by SceneKit.
        // We then add our box node to the root node of the scene.
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
    }

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        //  Retrieve the user’s tap location relative to the sceneView
        let tapLocation = recognizer.location(in: sceneView)
        // Searches the renderer’s scene for objects corresponding to a point in the rendered image
        let hitTestResults = sceneView.hitTest(tapLocation)

        guard let node = hitTestResults.first?.node else {
            // A feature point is a point automatically identified by ARKit as part of a continuous surface, but without a corresponding anchor.
            // It is basically the detected points on the surface of real world objects.
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                addBox(x: translation.x, y: translation.y, z: translation.z)
            }
            return
        }
        // If the result does contain at least a node, we will remove the first node we tapped on from its parent node.
        node.removeFromParentNode()
    }
    
    


}

// This extension transforms a matrix into float3. It gives us the x, y, and z from the matrix.
extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

