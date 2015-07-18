//
//  UIColor+Simplify.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 04/09/2014.
//  Copyright (c) 2014 Maxime de Chalendar. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
    * Returns a (hue, saturation, brightness, alpha) tuple, each value being in the [0,1] range
    */
    func HSBAComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if !getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return nil
        }
        return (hue, saturation, brightness, alpha)
    }
    
    /**
    * Returns a color where each RGB component is a random value between 0 and 255.
    */
    class func randomColor(alpha: CGFloat = 1) -> UIColor {
        let (r, g, b) = (
            CGFloat(arc4random_uniform(255)) / 255,
            CGFloat(arc4random_uniform(255)) / 255,
            CGFloat(arc4random_uniform(255)) / 255
        )
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
