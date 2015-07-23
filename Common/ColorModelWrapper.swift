//
//  ColorModelWrapper.swift
//  
//
//  Created by Maxime de Chalendar on 23/07/2015.
//
//

import UIKit

class ColorModelWrapper: NSObject, NSCopying, Equatable {

    var color: UIColor
    var white: (Float, Float)?
    
    init(color: UIColor, white: (Float, Float)? = nil) {
        self.color = color
        self.white = white
    }
    
    convenience init?(dictionary: [String: AnyObject]) {
        if let colorData = dictionary["color"] as? NSData {
            if let color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor {
                if let whiteRatio = dictionary["whiteRatio"] as? Float, whiteBrightness = dictionary["whiteBrightness"] as? Float {
                    self.init(color: color, white: (whiteRatio, whiteBrightness))
                }
                else {
                    self.init(color: color)
                }
                return
            }
        }

        // http://stackoverflow.com/questions/26495586/best-practice-to-implement-a-failable-initializer-in-swift
        self.init(color: UIColor.blackColor())
    }
    
    func toDictionary() -> [String:AnyObject] {
        if white == nil {
            return [ "color": NSKeyedArchiver.archivedDataWithRootObject(color) ]
        }
        else {
            return [
                "color": NSKeyedArchiver.archivedDataWithRootObject(color),
                "whiteRatio": white!.0,
                "whiteBrightness": white!.1
            ]
        }
    }
    
    func toTargetUpdate() -> LIFXTargetOperationUpdate {
        if let white = white {
            let targetUpdate = LIFXTargetOperationUpdate(kelvin: ratioToRawKelvin(white.0))
            targetUpdate.brightness = CGFloat(white.1)
            return targetUpdate
        }
        else {
            if let (h, s, b, _) = color.HSBAComponents() {
                let targetUpdate = LIFXTargetOperationUpdate(brightness: b)
                targetUpdate.saturation = s
                targetUpdate.hue = UInt(h * 360)
                return targetUpdate
            }
            return LIFXTargetOperationUpdate()
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return ColorModelWrapper(color: color, white: white)
    }
    
}

func == (lhs: ColorModelWrapper, rhs: ColorModelWrapper) -> Bool {
    return lhs.color == rhs.color && lhs.white?.0 == rhs.white?.0 && lhs.white?.1 == rhs.white?.1
}