//
//  TargetModelWrapper.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 01/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TargetModelWrapper: NSObject, LIFXTargetable {
    
    let identifier: String
    let name: String
    var selector: String
    
    init(identifier: String, name: String, selector: String) {
        self.identifier = identifier
        self.name = name
        self.selector = selector
    }
    
    convenience init(light: LIFXLight) {
        self.init(identifier:light.identifier, name:light.label, selector:light.targetSelector())
    }
    
    convenience init(group: LIFXBaseGroup) {
        self.init(identifier:group.identifier, name:group.name, selector:group.targetSelector())
    }
    
    convenience init?(dictionary: [String:String]) {
        if let identifier = dictionary["identifier"], name = dictionary["name"], selector = dictionary["selector"] {
            self.init(identifier:identifier, name:name, selector:selector)
        } else {
            // http://stackoverflow.com/questions/26495586/best-practice-to-implement-a-failable-initializer-in-swift
            self.init(identifier: "", name:"", selector:"")
            return nil
        }
    }
    
    func targetSelector() -> String! {
        return selector
    }
    
    func toDictionary() -> [String:String] {
        return [
            "identifier": self.identifier,
            "name":self.name,
            "selector":self.selector
        ]
    }
    
}