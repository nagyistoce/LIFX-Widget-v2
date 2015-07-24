//
//  TargetRowController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 30/01/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit
import WatchKit

class TargetRowController: NSObject {

    @IBOutlet var nameLabel: WKInterfaceLabel!

}

extension TargetRowController /* Public methods */ {
    
    func configureWithTarget(target: TargetModelWrapper) {
        nameLabel.setText(target.name)
    }
    
}
