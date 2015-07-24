//
//  IntensityRowController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 20/03/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit
import WatchKit

class IntensityRowController: NSObject {

    @IBOutlet weak var nameLabel: WKInterfaceLabel!

}

extension IntensityRowController /* Public methods */ {

    func configureWithIntensity(intensity: IntensityModelWrapper) {
        nameLabel.setText(intensity.name)
    }

}
