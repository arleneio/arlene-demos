//
//  ArleneAudience.swift
//  Arlene Live Streams
//
//  Created by Hermes on 2/6/20.
//  Copyright © 2020 Hermes. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import SafariServices

class ArleneAudience : ARAudience, SFSafariViewControllerDelegate {
    
    
    var remoteVideoViews: [UInt:UIView] = [:]
    var dataStreamId: Int! = 27                         // id for data stream
    var streamIsEnabled: Int32 = -1                     // acts as a flag to keep track if the data stream is enabled
    
    var shopNowBtn: UIButton!
    var shopNowLabel: UILabel?
    
    // MARK: Agora
    override func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteStateReason, elapsed: Int) {
        super.rtcEngine(engine, remoteVideoStateChangedOfUid: uid, state: state, reason: reason, elapsed: elapsed)
        if self.streamIsEnabled == -1 {
            // create the data stream
            self.streamIsEnabled = self.agoraKit.createDataStream(&self.dataStreamId, reliable: true, ordered: true)
            print("Data Stream initiated - STATUS: \(self.streamIsEnabled)")
        }
        if uid != self.remoteUser && state == .decoding {
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
        }
     }
    
    override func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        super.rtcEngine(engine, didOfflineOfUid: uid, reason: reason)
        if self.remoteUser == nil {
            guard let newHostViewDictRow = self.remoteVideoViews.popFirst() else { return }
            newHostViewDictRow.value.removeFromSuperview() // remove the remote view from the super view
            guard let remoteView = self.remoteVideoView else { return }
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = newHostViewDictRow.key
            videoCanvas.view = remoteView
            videoCanvas.renderMode = .hidden
            agoraKit.setupRemoteVideo(videoCanvas)
        } else if let remoteVideoView = self.remoteVideoViews[uid] {
            remoteVideoView.removeFromSuperview() // remove the remote view from the super view
            self.remoteVideoViews.removeValue(forKey: uid) // remove the remote view from the dictionary
        }
        adjustRemoteViews(remoteViews: self.remoteVideoViews, view: self.view)
    }
    
    override func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        // successfully received message from user
        print("STREAMID: \(streamId)\n - DATA: \(data)")
        let msg = decodeMsg(data)
        if msg != "" {
            switch msg {
            case "show":
                toggleShopNowButton(visible: true)
            case "hide":
                toggleShopNowButton(visible: false)
            default:
                print("unknown command: \(msg)")
            }
        }
    }
    
    // MARK: UI
    override func createUI() {
        super.createUI()
        
        // shop now UI
        let shopNowBtn = UIButton()
        shopNowBtn.frame = CGRect(x: self.view.frame.midX-(18.75), y: self.view.frame.maxY - 85, width: 37.5, height: 37.5)
        if let arBadge = UIImage(named: "sponsored-ar_badge") {
            shopNowBtn.setImage(arBadge, for: .normal)
            let shopNowLabel = UILabel()
            shopNowLabel.frame = CGRect(x: shopNowBtn.frame.midX-(30), y: shopNowBtn.frame.maxY+5, width: 60, height: 20)
            shopNowLabel.text = "shop now"
            shopNowLabel.textColor = .white
            shopNowLabel.adjustsFontSizeToFitWidth = true
            if let font = UIFont(name: "Helvetica", size: 10) {
                shopNowBtn.titleLabel?.font = font
            }
            shopNowLabel.isHidden = true
            self.shopNowLabel = shopNowLabel
            self.view.insertSubview(shopNowLabel, at: 2)
        } else {
            shopNowBtn.setTitle("shop now", for: .normal)
            shopNowBtn.setTitleColor(.white, for: .normal)
        }
        shopNowBtn.addTarget(self, action: #selector(showClickThrough), for: .touchUpInside)
        self.view.insertSubview(shopNowBtn, at: 2)
        self.shopNowBtn = shopNowBtn
        self.shopNowBtn.isHidden = true
        
//        self.removeAdsBtn = removeAdsBtn
//        self.removeAdsBtn.isHidden = true
    }
    
    @IBAction func showClickThrough(sender: UIButton) {
        let url: String = "https://arlene.io"
        DispatchQueue.main.async {
            self.viewClickThroughURL( url )
        }
    }
    
    func viewClickThroughURL(_ urlString: String ) {
        if let url = URL(string: urlString) {
            let sfvc = SFSafariViewController( url: url )
            sfvc.modalPresentationStyle = .overCurrentContext
            sfvc.delegate = self
            self.present(sfvc, animated: true)
        }
    }
    
    // MARK: Safari Delegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
    
    func toggleShopNowButton(visible: Bool) {
        guard let shopNowBtn = self.shopNowBtn else { return }
        shopNowBtn.isHidden = !visible
        guard let shopNowLabel = self.shopNowLabel else { return }
        shopNowLabel.isHidden = !visible
    }
}
