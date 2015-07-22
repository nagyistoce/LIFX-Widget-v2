//
//  IntensityTableViewCell.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 22/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class IntensityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var brightnessLabel: UILabel!
    
    func configureWithIntensity(intensity: IntensityModelWrapper) {
        titleLabel.text = intensity.name
        brightnessLabel.text = "\(Int(intensity.brightness * 100)) %"
    }
    
}