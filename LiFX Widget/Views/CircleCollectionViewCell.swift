//
//  CircleCollectionViewCell.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 23/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class CircleCollectionViewCell: UICollectionViewCell {

    var onSelectionColour: UIColor? {
        didSet {
            layer.borderColor = onSelectionColour?.CGColor
        }
    }
    override var selected: Bool {
        didSet {
            layer.borderWidth = selected ? 1 : 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        assert(CGRectGetWidth(bounds) == CGRectGetHeight(bounds), "CircleCollectionViewCell must be squared")
        layer.cornerRadius = CGRectGetWidth(bounds) / 2.0
        layer.masksToBounds = true
        layer.borderColor = onSelectionColour?.CGColor
    }
    
}