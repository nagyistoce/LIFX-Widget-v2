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
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var selectedView: TargetSelectedView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedView.setVisibleAnimated(visible: selected)
    }
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
    }
    
    private func configureWithLocation(location: LIFXLocation) {
        nameLabel.text = location.name
        typeLabel.text = "Location"
        backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    
    private func configureWithGroup(group: LIFXGroup) {
        nameLabel.text = group.name
        typeLabel.text = "Group"
        backgroundColor = UIColor(white: 0.98, alpha: 1)
    }

    private func configureWithLight(light: LIFXLight) {
        nameLabel.text = light.label
        typeLabel.text = "Bulb"
        backgroundColor = UIColor.whiteColor()
    }
    
}
