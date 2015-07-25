//
//  SceneRowController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 25/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit
import WatchKit

class SceneRowController: NSObject {
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!

}

extension SceneRowController /* Public methods */ {
    
    func configureWithScene(sceneModel: SceneModelWrapper) {
        nameLabel.setText(sceneModel.scene.name)
    }
    
}
