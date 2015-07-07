//
//  TargetTableViewCell.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 07/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TargetTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var indentationConstraint: NSLayoutConstraint!
    
}


// Configuration functions
extension TargetTableViewCell {

    func configureWithModel(model: LIFXModel) {
        if model is LIFXLocation {
            configureWithLocation(model as! LIFXLocation)
        }
        else if model is LIFXGroup {
            configureWithGroup(model as! LIFXGroup)
        }
        else if model is LIFXLight {
            configureWithLight(model as! LIFXLight)
        }
        
        indentationConstraint.constant = CGFloat(indentationLevel + 1) * indentationWidth
        layoutIfNeeded()
    }
    
    private func configureWithLocation(location: LIFXLocation) {
        nameLabel.text = location.name
        indentationLevel = 0
    }
    
    private func configureWithGroup(group: LIFXGroup) {
        nameLabel.text = group.name
        indentationLevel = 1
    }

    private func configureWithLight(light: LIFXLight) {
        nameLabel.text = light.label
        indentationLevel = 2
    }
    
}
