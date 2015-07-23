//
//  TargetCollectionViewCell.swift
//  
//
//  Created by Maxime de Chalendar on 23/07/2015.
//
//

import UIKit

class TargetCollectionViewCell: CircleCollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.lightGrayColor()
        onSelectionColour = UIColor.whiteColor()
    }
    
}

extension TargetCollectionViewCell /* Public methods */ {

    func configureWithTarget(target: TargetModelWrapper) {
        titleLabel.text = target.name
    }
    
}
