//
//  ColorRowController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 30/01/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit
import WatchKit

class ColorRowController: NSObject {
    
    @IBOutlet var mainGroup: WKInterfaceGroup!
    
}

extension ColorRowController /* Public methods */ {
    
    func configureWithColor(colorModel: ColorModelWrapper) {
        mainGroup.setBackgroundColor(colorModel.color)
    }

}
