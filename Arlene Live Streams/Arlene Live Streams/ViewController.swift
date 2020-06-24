//
//  ViewController.swift
//  Arlene Live Streams
//
//  Created by Hermes on 2/5/20.
//  Copyright © 2020 Hermes. All rights reserved.
//

import UIKit
import ARKit

class ViewController: AgoraLobbyVC  {

    // MARK: VC Events
    override func loadView() {
        super.loadView()
        
        AgoraARKit.agoraAppId = "66b9d68bd5a14be9b8d35c05fd34f88d"

        
        // set the banner image within the initial view
        if let arleneLogo = UIImage(named: "arlene-live-brandmark") {
            self.bannerImage = arleneLogo
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set images for UI elements within audience and broadcast view controllers
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Button Actions
    @IBAction override func joinSession() {
        if let channelName = self.userInput.text {
            if channelName != "" {
//                let arAudienceVC = ARAudience()
                let arAudienceVC = ArleneAudience()
                if let exitBtnImage = UIImage(named: "exit"),
                    let watermakerImage = UIImage(named: "Arlene-Logo") {
                    arAudienceVC.backBtnImage = exitBtnImage
                    arAudienceVC.watermarkImage = watermakerImage
                    arAudienceVC.watermarkFrame = CGRect(x: self.view.frame.maxX-175, y: self.view.frame.maxY-100, width: 150, height: 150)
                    arAudienceVC.watermarkAlpha = 0.5
                }
                arAudienceVC.channelName = channelName
                arAudienceVC.modalPresentationStyle = .fullScreen
                self.present(arAudienceVC, animated: true, completion: nil)
            } else {
               // TODO: add visible msg to user
               print("unable to join a broadcast without a channel name")
            }
        }
    }
    
    @IBAction override func createSession() {
        if let channelName = self.userInput.text {
            if channelName != "" {
                if ARFaceTrackingConfiguration.isSupported {
                    let arBroadcastVC = ArleneBroadcaster()
                    if let exitBtnImage = UIImage(named: "exit"),
                        let micBtnImage = UIImage(named: "mic"),
                        let muteBtnImage = UIImage(named: "mute"),
                        let watermakerImage = UIImage(named: "Arlene-Logo") {
                        arBroadcastVC.backBtnImage = exitBtnImage
                        arBroadcastVC.micBtnImage = micBtnImage
                        arBroadcastVC.muteBtnImage = muteBtnImage
                        arBroadcastVC.watermarkImage = watermakerImage
                        arBroadcastVC.watermarkFrame = CGRect(x: self.view.frame.maxX-135, y: self.view.frame.maxY-140, width: 100, height: 100)
                        arBroadcastVC.watermarkAlpha = 0.5
                    }
                    
                    arBroadcastVC.channelName = channelName
                    arBroadcastVC.modalPresentationStyle = .fullScreen
                    self.present(arBroadcastVC, animated: true, completion: nil)
                } else {
                    let broadcasterVC = Broadcaster()
                    if let exitBtnImage = UIImage(named: "exit"),
                        let micBtnImage = UIImage(named: "mic"),
                        let muteBtnImage = UIImage(named: "mute") {
                        broadcasterVC.backBtnImage = exitBtnImage
                        broadcasterVC.micBtnImage = micBtnImage
                        broadcasterVC.muteBtnImage = muteBtnImage
                    }
                    
                    broadcasterVC.channelName = channelName
                    broadcasterVC.modalPresentationStyle = .fullScreen
                    self.present(broadcasterVC, animated: true, completion: nil)
                }
            } else {
               // TODO: add visible msg to user
               print("unable to launch a broadcast without a channel name")
            }
        }
    }
    
}



