//
//  ColorPickerViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    private var currentColor: ColorModelWrapper?
    private var onColorSelection: ((ColorModelWrapper)->())?
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
        if currentColor?.white == nil {
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
        colorViewController.configureWithBaseColor(currentColor?.color) {
            self.currentColor?.color = $0
            self.currentColor?.white = nil
            self.updateLiveFeedbackTargetWithCurrentColor()
        }
    }
    
    private func updateLiveFeedbackTargetWithCurrentColor() {
        if let liveFeedbackTarget = self.liveFeedbackTarget {
            if let currentColor = currentColor {
                cancel_delay(cancelableDelayedLiveFeedback)
                cancelableDelayedLiveFeedback = delay(0.05) {
                    LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(currentColor.toTargetUpdate(), toTarget: liveFeedbackTarget, onCompletion: nil,
                        onFailure: { e in println("\(e) eeeee") })
                }
            }
        }
    }

}

// WhiteGradientViewController
extension ColorPickerViewController {
    
    private func configureWhiteViewController(whiteViewController: WhiteGradientViewController) {
        whiteViewController.configureWithWhite(currentColor?.white) { color, white in
            self.currentColor?.color = color
            self.currentColor?.white = white
            self.updateLiveFeedbackTargetWithCurrentColor()
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
    
    func configureWithBaseColor(baseColor: ColorModelWrapper?, feedbackLights: [LIFXLight], onColorSelection: (ColorModelWrapper)->()) {
        self.currentColor = baseColor ?? ColorModelWrapper(color: UIColor.randomColor())
        self.feedbackLights = feedbackLights
        self.onColorSelection = onColorSelection
    }
    
}

// Validation
extension ColorPickerViewController {

    private func validateSelectionAndDismiss() {
        if let currentColor = currentColor {
            onColorSelection?(currentColor)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
}
