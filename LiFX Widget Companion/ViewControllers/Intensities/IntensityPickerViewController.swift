//
//  IntensityPickerViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 22/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class IntensityPickerViewController: UIViewController {
    
    private var baseIntensity: IntensityModelWrapper?
    private var onIntensitySelection: (IntensityModelWrapper -> ())?
    private var liveFeedbackTarget: LIFXTargetable?
    private var feedbackLights: [LIFXLight]?
    private var cancelableDelayedLiveFeedback: dispatch_cancelable_closure?
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var brightnessSlider: UISlider!
    @IBOutlet private weak var brightnessLabel: UILabel!
    @IBOutlet weak var liveFeedbackTargetButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func tappedDoneButton(sender: UIBarButtonItem) {
        validateSelectionAndDismiss()
    }

    @IBAction func tappedMainView(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        updateLiveFeedbackTargetWithBrightness(sender.value)
        brightnessLabel.text = "\(Int(sender.value * 100)) %"
    }
    
    @IBAction func textfieldValueChanged(sender: UITextField) {
        doneButton.enabled = !sender.text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentIntensity = baseIntensity {
            nameTextField.text = currentIntensity.name
            brightnessSlider.value = currentIntensity.brightness
            brightnessLabel.text = "\(Int(currentIntensity.brightness * 100)) %"
            doneButton.enabled = true
        }
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

// UITextFieldDelegate
extension IntensityPickerViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// TargetPickerViewController
extension IntensityPickerViewController {
    
    private func configureTargetPickerViewController(targetPickerViewController: TargetPickerViewController) {
        targetPickerViewController.configureWithLights(feedbackLights!) { (light, name) in
            self.liveFeedbackTargetButton.title = "Live feedback on \(name)".uppercaseString
            self.liveFeedbackTarget = light
        }
    }
    
    private func updateLiveFeedbackTargetWithBrightness(brightness: Float) {
        if let liveFeedbackTarget = liveFeedbackTarget {
            let update = LIFXTargetOperationUpdate(brightness: CGFloat(brightness))
            
            cancel_delay(cancelableDelayedLiveFeedback)
            cancelableDelayedLiveFeedback = delay(0.05) {
                LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(update, toTarget: liveFeedbackTarget, onCompletion: nil, onFailure: nil)
            }
        }
    }
    
}

// Configuration
extension IntensityPickerViewController {
    
    func configureWithBaseIntensity(intensity: IntensityModelWrapper?, feedbackLights: [LIFXLight], onIntensitySelection: (IntensityModelWrapper ->())) {
        self.baseIntensity = intensity
        self.feedbackLights = feedbackLights
        self.onIntensitySelection = onIntensitySelection
    }
    
}

// Validation
extension IntensityPickerViewController {
    
    private func validateSelectionAndDismiss() {
        if !nameTextField.text.isEmpty {
            onIntensitySelection?(IntensityModelWrapper(name: nameTextField.text, brightness: brightnessSlider.value))
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
}