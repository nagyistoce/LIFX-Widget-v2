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
    @IBOutlet private weak var colorsButton: UIBarButtonItem!
    @IBOutlet private weak var whitesButtons: UIBarButtonItem!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var liveFeedbackTargetButton: UIBarButtonItem!
    @IBOutlet private weak var colorPickerView: MSHSBView!

    @IBAction func tappedDoneButton(sender: UIBarButtonItem) {
        validateSelectionAndDismiss()
    }
    
    @IBAction func tappedHeaderButton(sender: UIBarButtonItem) {
        if sender == colorsButton {
            contentScrollView.setContentOffset(CGPointZero, animated: true)
        } else {
            contentScrollView.setContentOffset(CGPointMake(CGRectGetWidth(contentScrollView.bounds), 0), animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeaderView()
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
        else if segue.identifier == "ColorViewController" {
            configureColorViewController(segue.destinationViewController as! ColorViewController)
        }
        else if segue.identifier == "WhiteGradientViewController" {
            configureWhiteViewController(segue.destinationViewController as! WhiteGradientViewController)
        }
    }

}

// UIScrollViewDelegate
extension ColorPickerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let pageWidth = CGRectGetWidth(scrollView.bounds)
        selectHeaderButtonsWithCurrentPageOffsetRatio(Float(xOffset / pageWidth))
    }
    
    private func configureHeaderView() {
        selectHeaderButtonsWithCurrentPageOffsetRatio(0)
    }
    
    private func selectHeaderButtonsWithCurrentPageOffsetRatio(offsetRatio: Float) {
        let font = UIFont.boldSystemFontOfSize(14)
        let selectedColor = UIColor(red: 35/255, green: 178/255, blue: 184/255, alpha: 1)
        let baseColor = UIColor.whiteColor()
        
        let rangedRatio = offsetRatio < 1 ? (1 - offsetRatio) : (offsetRatio - 1)
        colorsButton.setTitleTextAttributes([
            NSForegroundColorAttributeName : baseColor.colorByInterpolatingWithColor(selectedColor, ratio: rangedRatio),
            NSFontAttributeName: font], forState: .Normal)
        whitesButtons.setTitleTextAttributes([
            NSForegroundColorAttributeName : selectedColor.colorByInterpolatingWithColor(baseColor, ratio: rangedRatio),
            NSFontAttributeName: font], forState: .Normal)
    }
    
}

// ColorViewController
extension ColorPickerViewController {
    
    private func configureColorViewController(colorViewController: ColorViewController) {
        colorViewController.configureWithBaseColor(baseColor) { self.updateLiveFeedbackTargetWithColor($0) }
    }
    
    private func updateLiveFeedbackTargetWithColor(color: UIColor) {
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

// WhiteGradientViewController
extension ColorPickerViewController {
    
    // TODO: Use the whiteRatio and brightness parameters
    private func configureWhiteViewController(whiteViewController: WhiteGradientViewController) {
        whiteViewController.configureWithBaseRatio(nil, brightness: nil) { _, brightness, ratio in
            self.updateLiveFeedbackTargetWithWhiteRatio(ratio, brightness: brightness)
        }
    }
    
    private func updateLiveFeedbackTargetWithWhiteRatio(ratio: Float, brightness: Float) {
        if let liveFeedbackTarget = liveFeedbackTarget {
            let update = LIFXTargetOperationUpdate(kelvin: UInt(2500 + (9000 - 2500) * ratio))
            update.brightness = CGFloat(brightness)

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
            self.liveFeedbackTargetButton.title = "Live feedback on \(name)".uppercaseString
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
