//
//  ViewController.swift
//  AR_Ratings
//
//  Created by Jaf Crisologo on 2018-04-18.
//  Copyright © 2018 Jan Crisologo. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        if let imageName = imageAnchor.referenceImage.name {
            switch imageName {
            case "horizon":
                addTextNode(message: "\(cleanTitle(title: imageName)): 89")
            case "final-fantasy-xv":
                addTextNode(message: "\(cleanTitle(title: imageName)): 81")
            case "persona-5":
                addTextNode(message: "\(cleanTitle(title: imageName)): 93")
            case "crash":
                addTextNode(message: "\(cleanTitle(title: imageName)): 80")
                addWumpa()
            default:
                return
            }
        }
    }
    
    func addTextNode(message:String) {
        // Reset scene before displaying rating
        resetScene()
        let textScene = SCNText(string: "Metascore for \(message)", extrusionDepth: 0)
        textScene.materials.first?.diffuse.contents = UIColor.white
        let textNode = SCNNode(geometry: textScene)
        textNode.position = SCNVector3(-0.2, -0.25, -0.5)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func cleanTitle(title:String) -> String {
        let removeDashes = title.replacingOccurrences(of: "-", with: " ")
        return removeDashes.capitalized
    }
    
    func addWumpa() {
        resetScene()
        guard let wumpaScene = SCNScene(named: "wumpa.dae") else { return }
        let wumpaNode = SCNNode()
        let wumpaSceneChildNodes = wumpaScene.rootNode.childNodes
        
        for childNode in wumpaSceneChildNodes {
            wumpaNode.addChildNode(childNode)
        }
        
        wumpaNode.position = SCNVector3(x: 0, y: -0.25, z: -1)
        wumpaNode.scale = SCNVector3(0.05, 0.05, 0.05)
        
        let rotation = SCNAction.rotate(by: 360 * CGFloat((Double.pi)/180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
        let rotateForever = SCNAction.repeatForever(rotation)
        wumpaNode.runAction(rotateForever)
        
        sceneView.scene.rootNode.addChildNode(wumpaNode)
    }

    func resetScene() {
        DispatchQueue.main.async {
            self.removeNodes()
            let configuration = ARWorldTrackingConfiguration()
            guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
            }
            configuration.detectionImages = referenceImages
            self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    func removeNodes() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
}

