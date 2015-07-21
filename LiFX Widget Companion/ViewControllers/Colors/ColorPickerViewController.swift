//
//  ColorPickerViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    private var currentColor: UIColor?
    private var currentWhite: (Float, Float)?
    private var onColorSelection: ((UIColor, (Float, Float)?)->())?
    private var liveFeedbackTarget: LIFXTargetable?
    private var feedbackLights: [LIFXLight]?
    private var cancelableDelayedLiveFeedback: dispatch_cancelable_closure?
    private var hasConfiguredHeaderView = false
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !hasConfiguredHeaderView {
            hasConfiguredHeaderView = true
            configureHeaderView()
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
        if currentWhite == nil {
            contentScrollView.contentOffset = CGPoint.zeroPoint
        }
        else {
            contentScrollView.contentOffset = CGPoint(x: CGRectGetWidth(contentScrollView.bounds), y: 0)
        }
        scrollViewDidScroll(contentScrollView)
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
    
    private var displayedPage: Int {
        return Int(contentScrollView.contentOffset.x / CGRectGetWidth(contentScrollView.bounds))
    }
    
}

// ColorViewController
extension ColorPickerViewController {
    
    private func configureColorViewController(colorViewController: ColorViewController) {
        colorViewController.configureWithBaseColor(currentColor) {
            self.currentColor = $0
            self.updateLiveFeedbackTargetWithColor($0)
        }
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
        whiteViewController.configureWithWhite(currentWhite) { color, white in
            self.currentColor = color
            self.currentWhite = white
            self.updateLiveFeedbackTargetWithWhite(white)
        }
    }
    
    private func updateLiveFeedbackTargetWithWhite(white: (Float, Float)) {
        if let liveFeedbackTarget = liveFeedbackTarget {
            let update = LIFXTargetOperationUpdate(kelvin: ratioToRawKelvin(white.0))
            update.brightness = CGFloat(white.1)

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
    
    func configureWithBaseColor(baseColor: UIColor?, feedbackLights: [LIFXLight], onColorSelection: ((UIColor, (Float, Float)?)->())) {
        self.currentColor = baseColor
        self.feedbackLights = feedbackLights
        self.onColorSelection = onColorSelection
    }

    func configureWithBaseWhiteRatio(baseWhiteRatio: (Float, Float), feedbackLights: [LIFXLight], onColorSelection: ((UIColor, (Float, Float)?)->())) {
        self.currentWhite = baseWhiteRatio
        self.feedbackLights = feedbackLights
        self.onColorSelection = onColorSelection
    }
    
}

// Validation
extension ColorPickerViewController {

    private func validateSelectionAndDismiss() {
        if let currentColor = currentColor {
            if displayedPage == 0 {
                onColorSelection?(currentColor, nil)
            }
            else {
                onColorSelection?(currentColor, currentWhite)
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
}
