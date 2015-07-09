//
//  TargetSelectedView.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 08/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TargetSelectedView: UIView {
    
    var circleLayer: CAShapeLayer!
    var tickImageView: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        setupViewIfNeeded()
    }
}

// Setting up the view
extension TargetSelectedView {
    
    private func setupViewIfNeeded() {
        if circleLayer == nil && tickImageView == nil {
            createCircleLayer()
            createTickImageView()
        }
    }
    
    private func createCircleLayer() {
        circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.height/2).CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = tintColor.CGColor
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 1
        circleLayer.lineWidth = 1
        layer.addSublayer(circleLayer)
    }
    
    private func createTickImageView() {
        tickImageView = UIImageView(image: UIImage(named: "targets_selected_icon")?.imageWithRenderingMode(.AlwaysTemplate))
        tickImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(tickImageView)
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tickImageView]-|", options: .allZeros, metrics: nil, views: ["tickImageView" : tickImageView])
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[tickImageView]-|", options: .allZeros, metrics: nil, views: ["tickImageView" : tickImageView])
        addConstraints(hConstraints + vConstraints)
        layoutIfNeeded()
    }
}

// Public animation methods
extension TargetSelectedView {

    func setVisibleAnimated(#visible: Bool) {
        setupViewIfNeeded()

            if visible {
                circleLayer.strokeEnd = 1
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .allZeros,
                    animations: {
                        self.tickImageView.transform = CGAffineTransformIdentity
                }, completion: nil)
            }
            else {
                circleLayer.strokeEnd = 0
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn,
                    animations: {
                        self.tickImageView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                    }, completion: nil)
            }
    }

}
