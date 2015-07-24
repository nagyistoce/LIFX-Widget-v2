//
//  IntensityCollectionViewCell.swift
//  
//
//  Created by Maxime de Chalendar on 24/07/2015.
//
//

import UIKit

class IntensityCollectionViewCell: CircleCollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.lightGrayColor()
        onSelectionColour = UIColor.whiteColor()
    }

}

extension IntensityCollectionViewCell /* Public methods */ {
    
    func configureWithIntensity(intensity: IntensityModelWrapper) {
        titleLabel.text = intensity.name
    }
    
}