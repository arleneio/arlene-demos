//
//  Int+Extensions.swift
//  AR Drawing
//
//  Created by Hermes on 11/5/18.
//  Copyright © 2018 Arlene. All rights reserved.
//

import Foundation

internal extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
    
    mutating func toData() -> Data {
        return NSData(bytes: &self, length: MemoryLayout.size(ofValue:Int.self)) as Data
    }
}

internal extension Double {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
