//
//  TutorialViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 29/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    var onValidation: ([LIFXLight]->())?

    private var lights: [LIFXLight] = []

    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var pageControler: UIPageControl!
    @IBOutlet weak private var hiddenContentViewConstraint: NSLayoutConstraint!
    @IBOutlet weak private var hiddenValidOAuthTokenViewConstraint: NSLayoutConstraint!
    @IBOutlet private var pageViews: [TutorialView]!

    @IBAction private func pressedDoneButton(sender: UIButton) {
        dismissIfPossible()
    }

    @IBAction func tappedMainView(sender: UITapGestureRecognizer) {
        dismissIfPossible()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = .Custom
        modalPresentationCapturesStatusBarAppearance = true
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// Navigation
extension TutorialViewController {

    private func dismissIfPossible() {
        if SettingsPersistanceManager.sharedPersistanceManager.hasOAuthToken {
            dismissViewControllerAnimated(true) {
                onValidation?(lights)
            }
        } else {
            UIAlertView(title: "Authentication", message: "You need to setup your LIFX Cloud account in order to user LIFX Widget", delegate: nil, cancelButtonTitle: "Cancel").show()
            scrollToLIFXCloudSetupPage()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OAuthTokenPickerViewController" {
            configureOAuthPickerViewController(segue.destinationViewController as! OAuthTokenPickerViewController)
        }
    }
}

// OAuthToken
extension TutorialViewController {

    private func configureOAuthPickerViewController(OAuthPicker: OAuthTokenPickerViewController) {
        OAuthPicker.onValidation = { token in
            if let unwrappedToken = token {
                self.validateOAuthToken(unwrappedToken)
            }
        }
    }

    private func validateOAuthToken(OAuthToken: String) {
        let APIWrapper = LIFXAPIWrapper.sharedAPIWrapper()
        APIWrapper.setOAuthToken(OAuthToken)

        SVProgressHUD.showWithStatus("VALIDATING TOKEN...")
        APIWrapper.getAllLightsWithCompletion(
            { lights in
                SVProgressHUD.dismiss()
                self.lights = lights as! [LIFXLight]
                SettingsPersistanceManager.sharedPersistanceManager.OAuthToken = OAuthToken
                self.displayValidOAuthTokenView()
            },
            onFailure: { error in
                SVProgressHUD.dismiss()
                SettingsPersistanceManager.sharedPersistanceManager.OAuthToken = nil
                self.lights = []
                UIAlertView(title: "Error",
                    message: "We couldn't fetch your lights (\(error.localizedDescription)). You should probably generate a new token.",
                    delegate: nil, cancelButtonTitle: "Cancel").show()
            }
        )
    }

    private func displayValidOAuthTokenView() {
        hiddenValidOAuthTokenViewConstraint.priority = 250 // UILayoutPriorityDefaultLow
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros,
            animations: {
                self.scrollView.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension TutorialViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return pageViews.filter { touch.view.isDescendantOfView($0) }.isEmpty
    }

}

extension TutorialViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updatePageControlWithCurrentPage()
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updatePageControlWithCurrentPage()
        }
    }

    private var scrollViewPageWidth: Float {
        return Float(scrollView.bounds.width)
    }

    private func updatePageControlWithCurrentPage() {
        updatePageControlWithOffset(Float(scrollView.contentOffset.x))
    }

    private func updatePageControlWithOffset(xOffset: Float) {
        pageControler.currentPage = Int(xOffset / scrollViewPageWidth)
    }

    private func scrollToLIFXCloudSetupPage() {
        scrollToPageAtIndex(1)
    }

    private func scrollToPageAtIndex(index: Int) {
        let offsetForRequestedPage = scrollViewPageWidth * Float(index)
        updatePageControlWithOffset(offsetForRequestedPage)
        scrollView.setContentOffset(CGPoint(x: CGFloat(offsetForRequestedPage), y: 0), animated: true)
    }

}


extension TutorialViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is TutorialViewController {
            return TutorialAnimatedTransitioning(isPresenting: true)
        } else {
            return nil
        }
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is TutorialViewController {
            return TutorialAnimatedTransitioning(isPresenting: false)
        } else {
            return nil
        }
    }

    func layoutHiddenView() {
        hiddenContentViewConstraint.priority = 750 // UILayoutPriorityDefaultHigh
        view.layoutIfNeeded()
    }

    func layoutVisibleView() {
        hiddenContentViewConstraint.priority = 250 // UILayoutPriorityDefaultLow
        view.layoutIfNeeded()
    }
    
}
