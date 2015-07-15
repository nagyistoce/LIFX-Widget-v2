//
//  SeparatorView.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 15/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class SeparatorView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewConstraints = constraints() as! [NSLayoutConstraint]
        var heightConstraint = viewConstraints.filter { swiftFailsToDetectThisAsAnNSLayoutConstraint in
            let constraint = swiftFailsToDetectThisAsAnNSLayoutConstraint as NSLayoutConstraint
            return constraint.firstAttribute == .Height && constraint.constant == 1
        }.first
        heightConstraint?.constant = 1 / UIScreen.mainScreen().scale
    }

}
