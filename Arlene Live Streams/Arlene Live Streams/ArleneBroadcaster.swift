//
//  ArleneBroadcaster.swift
//  MeetMe Arlene Demo
//
//  Created by Hermes on 2/1/20.
//  Copyright © 2020 Hermes. All rights reserved.
//

import ARKit
import Arlene
import AgoraRtcEngineKit

class ArleneBroadcaster : ARBroadcaster {
    
    // Agora
    var sessionIsActive = false                         // keep track if the video session is active or not
    var dataStreamId: Int! = 27                         // id for data stream
    var streamIsEnabled: Int32 = -1                     // acts as a flag to keep track if the data stream is enabled
    var remoteVideoView: UIView!                        // video stream from remote user
    var remoteVideoViews: [UInt:UIView] = [:]
    
    // [Arlene] declare session
    lazy var arleneSession = Arlene.create(withSceneView: sceneView, viewController: self)
    
    // placements dictionary
    var placementsList: [Dictionary<String, String>]?
    var activePlacementIds: Dictionary<String,Bool> = [:]
    let adNodeRoot: SCNNode = SCNNode()
    var removeAdsBtn: UIButton!
    
    var rearCamPlacementBtns: [UIButton] = []
    var frontCamPlacementBtns: [UIButton] = []
    var faceNodes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.sceneView.scene.lightingEnvironment.contents = UIImage(named: "shinyRoom")
        
        // MARK: Initialize Arlene Session
        guard let appKey = getValueFromFile(withKey: "APP_ID", within: "keys") else { return }
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
    }
    
    override func setARConfiguration() {
        print("setARConfiguration")        // Configure ARKit Session
        let configuration = ARFaceTrackingConfiguration()
        // TODO: Enable Audio Data when iPhoneX bug is resolved
    //        configuration.providesAudioData = true  // AR session needs to provide the audio data
        configuration.isLightEstimationEnabled = true
        // run the config to start the ARSession
        self.sceneView.session.run(configuration)
        self.arvkRenderer?.prepare(configuration)
    }
    
    // plane detection
    override func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didAdd: node, for: anchor)
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
    
    @IBAction func removeAds() {
        self.removeAdsBtn.isHidden = true // hide button
        for (key, _) in self.activePlacementIds {
            print("remove placement: \(key)")
            self.arleneSession.removePlacement(withID: key, {(_) in
                print("removed placement: \(key)")
            })
            self.activePlacementIds.removeValue(forKey: key)
        }
        for faceNode in faceNodes {
            for adNode in faceNode.childNodes {
                adNode.removeFromParentNode()
            }
        }
        
        sendMsg("hide", toStreamWithId: dataStreamId, andState: streamIsEnabled, usingAgoraEngine: self.agoraKit)

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
                // keep track of the active placements
                if self.activePlacementIds[placementId] == nil {
                    self.activePlacementIds[placementId] = true
                }
                
                // show the remove ads icon
                if self.removeAdsBtn.isHidden {
                    self.removeAdsBtn.isHidden = false
                }
                
                // send message to show "shop now" button
                sendMsg("show", toStreamWithId: self.dataStreamId, andState: self.streamIsEnabled, usingAgoraEngine: self.agoraKit)
                
            }
        })
    }
    
    override func createUI() {
        super.createUI()
        // placement icons
        if let placements = getDictsFromFile(withKey: "PLACEMENTS", within: "placementsConfig") {
            print("add placement icons")
            for (index, placement) in placements.enumerated() {
                let placementBtn = UIButton()
                placementBtn.frame = CGRect(x: (self.view.frame.maxX-75)-CGFloat(index*60), y: (self.view.frame.maxY-75), width: 55, height: 55)
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
            self.placementsList = placements
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
    
    // Agora event handler
   override func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteStateReason, elapsed: Int) {
        super.rtcEngine(engine, remoteVideoStateChangedOfUid: uid, state: state, reason: reason, elapsed: elapsed)
        if state == .starting {
            lprint("firstRemoteVideoStarting for Uid: \(uid)", .Verbose)
        } else if state == .decoding {
            lprint("firstRemoteVideoDecoded for Uid: \(uid)", .Verbose)
            var remoteView: UIView
            if let existingRemoteView = self.remoteVideoViews[uid] {
                remoteView = existingRemoteView
            } else {
                remoteView = createRemoteView(remoteViews: self.remoteVideoViews, view: self.view)
            }
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.view = remoteView
            videoCanvas.renderMode = .hidden
            agoraKit.setupRemoteVideo(videoCanvas)
            self.view.insertSubview(remoteView, at: 2)
            self.remoteVideoViews[uid] = remoteView
            
            self.sessionIsActive = true
        }
    }
    
    override func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        super.rtcEngine(engine, didJoinChannel: channel, withUid: uid, elapsed: elapsed)
        print("local user did join channel with uid:\(uid)")
        // create the data stream
        self.streamIsEnabled = self.agoraKit.createDataStream(&self.dataStreamId, reliable: true, ordered: true)
        print("Data Stream initiated - STATUS: \(self.streamIsEnabled)")
    }
    
    override func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        super.rtcEngine(engine, didOfflineOfUid: uid, reason: reason)
        guard let remoteVideoView = self.remoteVideoViews[uid] else { return }
        remoteVideoView.removeFromSuperview() // remove the remote view from the super view
        self.remoteVideoViews.removeValue(forKey: uid) // remove the remote view from the dictionary
        adjustRemoteViews(remoteViews: self.remoteVideoViews, view: self.view)
    }
    
}
