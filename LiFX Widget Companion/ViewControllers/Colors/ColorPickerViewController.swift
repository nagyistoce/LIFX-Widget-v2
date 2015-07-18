//
//  ColorPickerViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    private var baseColor: UIColor?
    private var onColorSelection: ((UIColor)->())?
    @IBOutlet private weak var liveUpdateTargetButton: UIButton!
    @IBOutlet private weak var colorPickerView: MSHSBView!

    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.setColor(baseColor ?? UIColor.randomColor())
    }

    @IBAction func tappedDoneButton(sender: UIBarButtonItem) {
        validateSelectionAndDismiss()
    }
}

// Configuration
extension ColorPickerViewController {
    
    func configureWithBaseColor(baseColor: UIColor?, onColorSelection: ((UIColor)->())) {
        self.baseColor = baseColor
        self.onColorSelection = onColorSelection
    }
    
}

// Validation
extension ColorPickerViewController {

    private func validateSelectionAndDismiss() {
        onColorSelection?(colorPickerView.color())
        navigationController?.popViewControllerAnimated(true)
    }
    
}
