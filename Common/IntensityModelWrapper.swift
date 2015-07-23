//
//  IntensityModelWrapper.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 22/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class IntensityModelWrapper: NSObject, Equatable {
    
    let name: String
    let brightness: Float
    
    init(name: String, brightness: Float) {
        self.name = name
        self.brightness = brightness
    }
    
    convenience init?(dictionary: [String:AnyObject]) {
        if let name = dictionary["name"] as? String, brightness = dictionary["brightness"] as? Float {
            self.init(name:name, brightness:brightness)
        } else {
            // http://stackoverflow.com/questions/26495586/best-practice-to-implement-a-failable-initializer-in-swift
            self.init(name:"", brightness:0)
            return nil
        }
    }
    
    func toDictionary() -> [String:AnyObject] {
        return [
            "name": name,
            "brightness": brightness
        ]
    }
    
    func toTargetUpdate() -> LIFXTargetOperationUpdate {
        return LIFXTargetOperationUpdate(brightness: CGFloat(brightness))
    }
    
}

func == (lhs: IntensityModelWrapper, rhs: IntensityModelWrapper) -> Bool {
    return lhs.name == rhs.name && lhs.brightness == rhs.brightness
}