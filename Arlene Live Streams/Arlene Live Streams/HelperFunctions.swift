//
//  HelperFunctions.swift
//  Arlene Demo
//
//  Created by Macbook on 6/21/19.
//  Copyright © 2019 Macbook. All rights reserved.
//

import Foundation
import UIKit
import AgoraRtcEngineKit

// helper function

//MARK: Data Retrieval
func getValueFromFile(withKey keyId:String, within fileName: String) -> String? {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist") else { return nil }
    guard let plist = NSDictionary(contentsOfFile: filePath) else { return nil }
    let value:String = plist.object(forKey: keyId) as! String
    if value == "" {
        return nil
    }
    return value
}

func getDictsFromFile(withKey keyId:String, within fileName: String) -> [Dictionary<String, String>]? {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist")  else { return nil }
    guard let plist = NSDictionary(contentsOfFile: filePath)  else { return nil }
    let value:[Dictionary] = plist.object(forKey: keyId) as! [Dictionary<String, String>]
    if value.count == 0 {
        return nil
    }
    return value
}

// MARK: Remote Views
func createRemoteView(remoteViews: [UInt:UIView], view: UIView) -> UIView {
   let offset = remoteViews.count
   let remoteViewScale = view.frame.width * 0.33
   let yPos = (remoteViewScale * CGFloat(offset)) + 25
   let remoteView = UIView()
   remoteView.frame = CGRect(x: view.frame.minX+15, y: view.frame.minY+yPos, width: remoteViewScale, height: remoteViewScale)
   remoteView.backgroundColor = UIColor.lightGray
   remoteView.layer.cornerRadius = 25
   remoteView.layer.masksToBounds = true
   return remoteView
}

func adjustRemoteViews(remoteViews: [UInt:UIView], view: UIView) {
    for (index, remoteViewDictRow) in remoteViews.enumerated() {
        let remoteView = remoteViewDictRow.value
        let offset = CGFloat(index)
        let remoteViewScale = remoteView.frame.width
        remoteView.frame.origin.y = (remoteViewScale * offset) + 25
    }
}

// MARK: Stream Msgs
func sendMsg(_ msg: String, toStreamWithId dataStreamId: Int, andState streamState: Int32, usingAgoraEngine agoraKit: AgoraRtcEngineKit) {
    if streamState == 0 {
        print("sending stream msg: \(msg)")
        agoraKit.sendStreamMessage(dataStreamId, data: msg.data(using: String.Encoding.ascii)!)
    }
}

func decodeMsg(_ data: Data) -> String {
    if let dataAsString = String(bytes: data, encoding: String.Encoding.ascii) {
        return dataAsString
    } else {
        return ""
    }
}
