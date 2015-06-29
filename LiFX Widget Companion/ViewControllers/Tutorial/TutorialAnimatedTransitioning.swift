//
//  TutorialAnimatedTransitioning.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 29/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TutorialAnimatedTransitioning: NSObject {

    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
}

extension TutorialAnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(transitionContext)
        } else {
            animateDismissal(transitionContext)
        }
    }

    func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        let tutorialViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! TutorialViewController
        let presentingView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let containerView = transitionContext.containerView()
        let duration = transitionDuration(transitionContext)

        tutorialViewController.view.alpha = 0
        containerView.addSubview(tutorialViewController.view)
        tutorialViewController.layoutHiddenView()

        UIView.animateWithDuration(duration / 3,
            animations: {
                tutorialViewController.view.alpha = 1
            }, completion: { finished in

                UIView.animateWithDuration(duration / 3 * 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros,
                    animations: {
                        tutorialViewController.layoutVisibleView()
                    },
                    completion: { finished in
                        transitionContext.completeTransition(true)
                    }
                )
            }
        )

    }

    func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        let tutorialViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! TutorialViewController
        let duration = transitionDuration(transitionContext)

        UIView.animateWithDuration(duration / 3 * 2, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros,
            animations: {
                tutorialViewController.layoutHiddenView()
            }, completion: { finished in

                UIView.animateWithDuration(duration / 3,
                    animations: {
                        tutorialViewController.view.alpha = 0
                    },
                    completion: { finished in
                        transitionContext.completeTransition(true)
                    }
                )
            }
        )
    }
}
