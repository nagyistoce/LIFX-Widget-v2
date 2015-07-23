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
    
    /**
    * Returns a (red, green, blue, alpha) tuple, each value being in the [0,1] range
    */
    func RGBComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if !getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return nil
        }
        return (red, green, blue, alpha)
    }
    
    /**
    * Returns an interpolation of the two given colors.
    * Returns `self` on failure.
    */
    func colorByInterpolatingWithColor(color: UIColor, ratio: Float) -> UIColor {
        let rangedRatio = max(min(1, ratio), 0)
        if rangedRatio == 0 {
            return self
        }
        else if rangedRatio == 1 {
            return color
        }
        else {
            if let (red, green, blue, alpha) = RGBComponents(), (otherRed, otherGreen, otherBlue, otherAlpha) = color.RGBComponents() {
                let outputRed = red + (otherRed - red) * CGFloat(rangedRatio)
                let outputGreen = green + (otherGreen - green) * CGFloat(rangedRatio)
                let outputBlue = blue + (otherBlue - blue) * CGFloat(rangedRatio)
                let outputAlpha = alpha + (otherAlpha - alpha) * CGFloat(rangedRatio)
                return UIColor(red: outputRed, green: outputGreen, blue: outputBlue, alpha: outputAlpha)
            }
            return self
        }
    }
    
    
    /**
    * Returns a UIColor which represents a given kelvin ration
    */
    convenience init(kelvionRatio: Float) {
        let maximumKelvinRatioColor = UIColor.whiteColor()
        let minimumKelvinRatioColor = UIColor(red: 251/255, green: 220/255, blue: 175/255, alpha: 1)
        if let (r, g, b, a) = minimumKelvinRatioColor.colorByInterpolatingWithColor(maximumKelvinRatioColor, ratio: kelvionRatio).RGBComponents() {
            self.init(red: r, green: g, blue: b, alpha: a)
        } else {
            self.init()
        }
    }
    
}
