//
//  SceneTableViewCell.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 25/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class SceneTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var selectedView: TableViewCellSelectedView!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedView.setVisibleAnimated(visible: selected)
    }
}

// Configuration functions
extension SceneTableViewCell {

    func configureWithScene(scene: SceneModelWrapper) {
        nameLabel.text = scene.scene.name
    }
    
}