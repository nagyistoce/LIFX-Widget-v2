//
//  TutorialViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 29/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak var pageControler: UIPageControl!
    @IBOutlet weak private var hiddenContentViewConstraint: NSLayoutConstraint!

    @IBAction private func pressedDoneButton(sender: UIButton) {
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

}

// Navigation
extension TutorialViewController {

    private func dismissIfPossible() {
        if SettingsPersistanceManager.sharedPersistanceManager.hasOAuthToken {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            UIAlertView(title: "Authentication", message: "You need to setup your LIFX Cloud account in order to user LIFX Widget", delegate: nil, cancelButtonTitle: "Cancel").show()
            scrollToPageAtIndex(1)
        }
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
