//
//  SceneModelWrapper.swift
//  
//
//  Created by Maxime de Chalendar on 25/07/2015.
//
//

import UIKit

class SceneModelWrapper: NSObject {
    
    let scene: LIFXScene
    
    init(scene: LIFXScene) {
        self.scene = scene
    }
    
    convenience init(dictionary: [String:AnyObject]) {
        self.init(scene: LIFXScene(dictionary: dictionary))
    }
    
    func toDictionary() -> [String:AnyObject] {
        return scene.toDictionary() as! [String:AnyObject]
    }
    
}
