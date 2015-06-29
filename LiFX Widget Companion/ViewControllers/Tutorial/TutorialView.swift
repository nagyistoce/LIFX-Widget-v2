//
//  TutorialView.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 28/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TutorialView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.bounds.width / 15
    }

}
