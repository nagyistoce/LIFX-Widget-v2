//
//  ColorViewController.swift
//  
//
//  Created by Maxime de Chalendar on 20/07/2015.
//
//

import UIKit

class ColorViewController: UIViewController {
    
    private var baseColor: UIColor?
    private var onColorSelection: ((UIColor)->())?
    private var colorPickerView: MSHSBView {
        return view as! MSHSBView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureColorView()
    }

}

// MSColorViewDelegate
extension ColorViewController: MSColorViewDelegate {
    
    private func configureColorView() {
        colorPickerView.delegate = self
        colorPickerView.setColor(baseColor ?? UIColor.randomColor())
    }
    
    func colorView(colorView: MSColorView!, didChangeColor color: UIColor!) {
        onColorSelection?(color)
    }
}

// Configuration
extension ColorViewController {
    
    func configureWithBaseColor(baseColor: UIColor?, onColorSelection: ((UIColor)->())) {
        self.baseColor = baseColor
        self.onColorSelection = onColorSelection
    }
    
}