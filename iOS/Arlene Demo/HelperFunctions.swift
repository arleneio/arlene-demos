//
//  HelperFunctions.swift
//  Arlene Demo
//
//  Created by Macbook on 6/21/19.
//  Copyright © 2019 Macbook. All rights reserved.
//

import Foundation

// helper function
func getValueFromFile(withKey keyId:String, within fileName: String) -> String {
    let filePath = Bundle.main.path(forResource: fileName, ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    let value:String = plist?.object(forKey: keyId) as! String
    return value
}

func getDictsFromFile(withKey keyId:String, within fileName: String) -> [Dictionary<String, String>] {
    let filePath = Bundle.main.path(forResource: fileName, ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    let value:[Dictionary] = plist?.object(forKey: keyId) as! [Dictionary<String, String>]
    return value
}
