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
    private var liveFeedbackTarget: LIFXTargetable?
    private var feedbackLights: [LIFXLight]?
    private var cancelableDelayedLiveFeedback: dispatch_cancelable_closure?
    @IBOutlet private weak var liveFeedbackTargetButton: UIButton!
    @IBOutlet private weak var colorPickerView: MSHSBView!

    @IBAction func tappedDoneButton(sender: UIBarButtonItem) {
        validateSelectionAndDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColorView()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "TargetPickerViewController" {
            return feedbackLights != nil
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TargetPickerViewController" {
            configureTargetPickerViewController(segue.destinationViewController as! TargetPickerViewController)
        }
    }

}

// MSColorViewDelegate
extension ColorPickerViewController: MSColorViewDelegate {
    
    private func configureColorView() {
        colorPickerView.delegate = self
        colorPickerView.setColor(baseColor ?? UIColor.randomColor())
    }
    
    func colorView(colorView: MSColorView!, didChangeColor color: UIColor!) {
        if let (hue, saturation, brightness, _) = color.HSBAComponents(), let liveFeedbackTarget = liveFeedbackTarget {
            let update = LIFXTargetOperationUpdate(brightness: brightness)
            update.hue = UInt(hue * 360)
            update.saturation = saturation

            cancel_delay(cancelableDelayedLiveFeedback)
            cancelableDelayedLiveFeedback = delay(0.05) {
                LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(update, toTarget: liveFeedbackTarget, onCompletion: nil, onFailure: nil)
            }
        }
    }
    
}

// TargetPickerViewController
extension ColorPickerViewController {
    
    private func configureTargetPickerViewController(targetPickerViewController: TargetPickerViewController) {
        targetPickerViewController.configureWithLights(feedbackLights!) { (light, name) in
            self.liveFeedbackTargetButton.setTitle("Live feedback on \(name)".uppercaseString, forState: .Normal)
            self.liveFeedbackTarget = light
        }
    }
    
}

// Configuration
extension ColorPickerViewController {
    
    func configureWithBaseColor(baseColor: UIColor?, feedbackLights: [LIFXLight], onColorSelection: ((UIColor)->())) {
        self.baseColor = baseColor
        self.feedbackLights = feedbackLights
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
