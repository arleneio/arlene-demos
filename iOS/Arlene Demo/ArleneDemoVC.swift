//
//  ArleneDemoVC.swift
//  Arlene Demo
//
//  Created by Macbook on 12/15/19.
//  Copyright © 2019 Macbook. All rights reserved.
//

import UIKit
import ARKit
import Arlene


class ArleneDemoVC: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    
    enum cameraFacing {
        case front
        case back
    }
    
    var activeCam: cameraFacing = .back
    
    // placements dictionary
    var placementsList: [Dictionary<String, String>]?
    var activePlacementIds: Dictionary<String,Bool> = [:]
    let adNodeRoot: SCNNode = SCNNode()
    var removeAdsBtn: UIButton!
    
    var rearCamPlacementBtns: [UIButton] = []
    var frontCamPlacementBtns: [UIButton] = []
    var faceNodes: [SCNNode] = []
    
    let debug : Bool = false
    
    private var planes = [UUID: Plane]()
    
    // [Arlene] declare session
    lazy var arleneSession = Arlene.create(withSceneView: sceneView, viewController: self)
    
    // MARK: VC Events
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.black       // set the background color
        
        // Setup sceneview
        let sceneView = ARSCNView() //instantiate scene view
        self.view.insertSubview(sceneView, at: 0)
        
        //add sceneView layout contstraints
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        // set reference to sceneView
        self.sceneView = sceneView
        
        // back button
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: self.view.frame.minX+20, y: self.view.frame.minY + 20, width: 45, height: 45)
        backBtn.layer.cornerRadius = 10
        if let backIcon = UIImage(named: "arlene-brandmark") {
            backBtn.setImage(backIcon, for: .normal)
        } else {
            backBtn.setTitle("back", for: .normal)
            backBtn.setTitleColor(.white, for: .normal)
        }
        backBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        self.view.insertSubview(backBtn, at: 2)
        
        // flip camera button
        if ARFaceTrackingConfiguration.isSupported {
            let flipCamBtn = UIButton()
            flipCamBtn.frame = CGRect(x:self.view.frame.maxX-65, y:self.view.frame.minY+25, width: 40, height: 40)
            if let flipCamIcon = UIImage(named: "flip-camera") {
                flipCamBtn.setImage(flipCamIcon, for: .normal)
            } else {
                flipCamBtn.setTitle("^v", for: .normal)
                flipCamBtn.setTitleColor(.white, for: .normal)
            }
            flipCamBtn.addTarget(self, action: #selector(cameraFlipBtnTap), for: .touchDown)
            self.view.insertSubview(flipCamBtn, at: 2)
        }
        
        //placement buttons
        guard let placemnts = self.placementsList else { return }
        for (index, placement) in placemnts.enumerated() {
            if debug {
                print(placement)
            }
            let placementBtn = UIButton()
            var offset: Int
            if placement["CAM"] == "back" {
                rearCamPlacementBtns.append(placementBtn)
                offset = rearCamPlacementBtns.count-1
            } else if placement["CAM"] == "front" {
                frontCamPlacementBtns.append(placementBtn)
                placementBtn.isHidden = true
                offset = frontCamPlacementBtns.count-1
            } else {
                return
            }
            placementBtn.frame = CGRect(x: (self.view.frame.maxX-75)-CGFloat(offset*60), y: (self.view.frame.maxY-75), width: 55, height: 55)
            if let placementIcon = UIImage(named: placement["ICON"]!) {
                placementBtn.setImage(placementIcon, for: .normal)
            } else {
                placementBtn.setTitle( placement["NAME"]!, for: .normal)
                placementBtn.setTitleColor(.white, for: .normal)
            }
            placementBtn.tag = index
            placementBtn.addTarget(self, action: #selector(placementButtonTap(sender:)), for: .touchUpInside)
            self.view.insertSubview(placementBtn, at: 3)
        }
        
        // waste bin
        let removeAdsBtn = UIButton()
        removeAdsBtn.frame = CGRect(x: self.view.bounds.minX + 35, y: self.view.bounds.maxY - 75, width: 40, height: 40)
        if let wasteBin = UIImage(named: "waste-bin") {
            removeAdsBtn.setImage(wasteBin, for: .normal)
        } else {
            removeAdsBtn.setTitle("remove", for: .normal)
            removeAdsBtn.setTitleColor(.white, for: .normal)
        }
        removeAdsBtn.addTarget(self, action: #selector(removeAds), for: .touchUpInside)
        self.view.insertSubview(removeAdsBtn, at: 2)
        // set reference to removeMojiBtn
        self.removeAdsBtn = removeAdsBtn
        self.removeAdsBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Initialize Arlene Session
        let appKey = getValueFromFile(withKey: "APP_ID", within: "keys")
        Arlene.setAppKey(appKey)
        
        arleneSession.initialise { (result, error) in
            if let error = error {
                print ("Failed to initialise Arlene: \(error)")
            }
            else {
                if result {
                    print("Successfully initialized Arlene SDK")
                    self.arleneSession.developmentMode = false
                }
            }
        }
        
        if debug {
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin , ARSCNDebugOptions.showFeaturePoints]
            sceneView.showsStatistics = true
        }
        
        let configuration = ARWorldTrackingConfiguration()
        //        configuration.planeDetection = [.horizontal, .vertical]
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        // add the adRootNode to the scene
        self.sceneView.scene.rootNode.addChildNode(self.adNodeRoot)
    }
    
    // MARK: Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Render Delegate
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // must call Arlene during render
        arleneSession.render()
    }
    
    // plane detection
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if self.activeCam == .back {
            // we only care about planes
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            if debug {
                NSLog("Found plane: \(planeAnchor)") }
            } else if self.activeCam == .front {
                guard let sceneView = renderer as? ARSCNView, anchor is ARFaceAnchor else { return }
                /*
                 Write depth but not color and render before other objects.
                 This causes the geometry to occlude other SceneKit content
                 while showing the camera view beneath, creating the illusion
                 that real-world objects are obscuring virtual 3D objects.
                 */
                let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
                faceGeometry.firstMaterial!.colorBufferWriteMask = []
                let occlusionNode = SCNNode(geometry: faceGeometry)
                occlusionNode.renderingOrder = -1
                
                let contentNode = SCNNode()
                contentNode.addChildNode(occlusionNode)
                node.addChildNode(contentNode)
                faceNodes.append(node)
            }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
     
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //print("Anchor removed \(anchor)")
        planes.removeValue(forKey: anchor.identifier)
    }
    
    // MARK: Button Events
    @IBAction func popView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func placementButtonTap(sender: UIButton) {
        print(sender.tag)
        let placement = self.placementsList![sender.tag]
        guard let placementId = placement["KEY"] else { return }
        self.arleneSession.fetchPlacement(withID: placementId,  { (placementId, result, error) in
           print("fetchPlacement \(placementId) \(result)")
        })
        
        // set up parent node
        let adNodeParent = SCNNode()

        // Call immediately.  The load operation will be queued
        self.arleneSession.loadPlacement(withID: placementId, toNode: adNodeParent, autoRemove: false, { (placementId, result, error) in
            print("loadPlacement \(placementId) \(result)")
            if result == .success {
               // upon successful load, add the advertisement to the scene as a child of the adRootNode
                if placement["CAM"] == "back" {
                    var xPos = 0.25 + (0.5 * Double(sender.tag))
                    let halfList = self.placementsList!.count/2
                    if sender.tag >= halfList {
                        xPos = -1 * (0.25 + (0.25 * Double(sender.tag % halfList)))
                    }
                    adNodeParent.position = SCNVector3(xPos, -0.25, -1)
                    self.adNodeRoot.addChildNode(adNodeParent)
                } else if placement["CAM"] == "front" {
                    
                    if placement["NAME"] == "Baseball Cap" {
                        adNodeParent.position = SCNVector3(0, 0.07, -0.075)
                        adNodeParent.eulerAngles = SCNVector3(0, 180.degreesToRadians, 0)
                    } else if placement["NAME"] == "Sunglasses" {
                        adNodeParent.scale = SCNVector3(12.75,12.75,12.75)
                        adNodeParent.position = SCNVector3(0, 0, 0.055)
                    }
                    
                    for (index, node) in self.faceNodes.enumerated() {
                        if index == 0 {
                            node.addChildNode(adNodeParent)
                        } else {
                            let parentClone = adNodeParent.clone()
                            node.addChildNode(parentClone)
                        }
                    }
                } else {
                    return
                }
                // keep track of the active placements
                if self.activePlacementIds[placementId] == nil {
                    self.activePlacementIds[placementId] = true
                }
            }
        })
        
        // show the remove ads icon
        if self.removeAdsBtn.isHidden {
            self.removeAdsBtn.isHidden = false
        }
    }
    
    @IBAction func removeAds() {
        self.removeAdsBtn.isHidden = true // hide button
        for (key, _) in self.activePlacementIds {
            print("remove placement: \(key)")
            self.arleneSession.removePlacement(withID: key, {(_) in
                print("removed placement: \(key)")
            })
            self.activePlacementIds.removeValue(forKey: key)
        }
        if activeCam == .back {
            for adChild in self.adNodeRoot.childNodes {
                adChild.removeFromParentNode()
            }
        } else {
            for faceNode in faceNodes {
                for adNode in faceNode.childNodes {
                    adNode.removeFromParentNode()
                }
            }
        }

    }
    
    // MARK: Camera Flip
    @objc func cameraFlipBtnTap() {
        if self.activeCam == .back {
            // switch to front config
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            //clean up the scene
            for childNode in self.sceneView.scene.rootNode.childNodes {
                childNode.removeFromParentNode()
            }
            for btn in rearCamPlacementBtns {
                btn.isHidden = true
            }
            for btn in frontCamPlacementBtns {
                btn.isHidden = false
            }
            // run the config to swap the camera
            self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            self.activeCam = .front
        } else {
            // switch to back cam config
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.isLightEstimationEnabled = true
            // clean up the scene
            for childNode in self.sceneView.scene.rootNode.childNodes {
                childNode.removeFromParentNode()
            }
            for btn in rearCamPlacementBtns {
                btn.isHidden = false
            }
            for btn in frontCamPlacementBtns {
                btn.isHidden = true
            }
            // run the config to swap the camera
            self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            self.activeCam = .back
        }
    }
}

