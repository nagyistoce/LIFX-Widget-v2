//
//  ColorCollectionViewCell.swift
//  
//
//  Created by Maxime de Chalendar on 23/07/2015.
//
//

import UIKit

class ColorCollectionViewCell: CircleCollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        onSelectionColour = UIColor.lightGrayColor()
    }

}

extension ColorCollectionViewCell /* Public methods */ {
    
    func configureWithColor(colorModel: ColorModelWrapper) {
        backgroundColor = colorModel.color
    }
    
}
