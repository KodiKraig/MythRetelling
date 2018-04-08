//
//  Extensions.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/8/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

extension UIView {
    
    func shake(distance: CGFloat) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - distance, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + distance, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
}

extension String {
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

extension UIDevice {
    func isIPhone() -> Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.contains("iPhone")
    }
}
