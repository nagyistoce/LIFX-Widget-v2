//
//  SceneCollectionViewCell.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 25/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class SceneCollectionViewCell: CircleCollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.lightGrayColor()
        onSelectionColour = UIColor.whiteColor()
    }
    
}

extension SceneCollectionViewCell /* Public methods */ {
    
    func configureWithScene(sceneModel: SceneModelWrapper) {
        titleLabel.text = sceneModel.scene.name
    }
    
}
