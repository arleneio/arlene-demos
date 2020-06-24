//
//  UIFont+extension.swift
//  Arlene Live Streams
//
//  Created by Hermes on 2/7/20.
//  Copyright © 2020 Hermes. All rights reserved.
//

import UIKit

extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
