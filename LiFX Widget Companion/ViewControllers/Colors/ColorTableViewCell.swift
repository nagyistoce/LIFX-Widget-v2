//
//  ColorTableViewCell.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class ColorTableViewCell: UITableViewCell {
    
}

// Configuration fuctions
extension ColorTableViewCell {
    
    override func layoutSubviews() {
        // http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = false;

        super.layoutSubviews()
    }
    
    
    func configureWithColor(colorModel: ColorModelWrapper) {
        backgroundColor = colorModel.color
    }
    
}
