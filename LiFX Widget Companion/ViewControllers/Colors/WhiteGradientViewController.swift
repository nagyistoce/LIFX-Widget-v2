//
//  WhiteGradientView.swift
//  
//
//  Created by Maxime de Chalendar on 19/07/2015.
//
//

import UIKit

class WhiteGradientViewController: UIViewController {

    private var currentWhite: (Float, Float)?
    private var onWhiteSelection: ((UIColor, (Float, Float))->())?

    private var currentBrightness: Float {
        return brightnessSlider.value
    }
    private var currentRatio: Float {
        return Float(indicatorYPosition.constant / CGRectGetHeight(gradientView.bounds))
    }
    private var currentColor: UIColor {
        return UIColor(kelvionRatio: currentRatio)
    }
    
    private var hasPositionedIndicatorView = false
    private var gradientLayer: CAGradientLayer!
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var brightnessSlider: UISlider!
    @IBOutlet private weak var indicatorView: UIView!
    @IBOutlet private weak var indicatorYPosition: NSLayoutConstraint!
    @IBOutlet private weak var indicatorXPosition: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColorView()
        setupGradientView()
        setupIndicatorView()
        setupBrightnessSlider()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateGradientLayerFrame()
        if !hasPositionedIndicatorView {
            hasPositionedIndicatorView = true

            var position = CGPoint(x: CGRectGetWidth(gradientView.bounds) / 2, y: CGRectGetHeight(gradientView.bounds) / 2)
            if let currentWhite = currentWhite {
                position.y = CGRectGetHeight(gradientView.bounds) * CGFloat(currentWhite.0)
            }
            updateColorWithPosition(position, callOnWhiteSelection: false)
        }
    }

    @IBAction func tappedGradientView(sender: UITapGestureRecognizer) {
        updateColorWithPosition(sender.locationInView(gradientView))
    }
    
    @IBAction func pannedGradientView(sender: UIPanGestureRecognizer) {
        var position = sender.locationInView(gradientView)
        position.x = max(0, min(position.x, CGRectGetWidth(gradientView.bounds)))
        position.y = max(0, min(position.y, CGRectGetHeight(gradientView.bounds)))

        updateColorWithPosition(position)
    }
    
    @IBAction func sliderChangedValue(sender: UISlider) {
        onWhiteSelection?(currentColor, (currentRatio, currentBrightness))
    }
}

// View Setup
extension WhiteGradientViewController {
    
    private func setupGradientView() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(kelvionRatio: 0).CGColor, UIColor(kelvionRatio: 1).CGColor]
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientLayer)
        
        gradientView.layer.borderColor = UIColor.blackColor().CGColor
        gradientView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
    }
    
    private func setupIndicatorView() {
        let indicatorLayer = indicatorView.layer
        indicatorLayer.cornerRadius = CGRectGetWidth(indicatorView.bounds) / 2
        indicatorLayer.borderWidth = 2
        indicatorLayer.borderColor = UIColor(white: 0.9, alpha: 0.8).CGColor
        indicatorLayer.shadowColor = UIColor.blackColor().CGColor
        indicatorLayer.shadowOffset = CGSize.zeroSize
        indicatorLayer.shadowRadius = 1
        indicatorLayer.shadowOpacity = 0.5
    }
    
    private func setupColorView() {
        colorView.layer.borderColor = UIColor.blackColor().CGColor
        colorView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
    }
    
    private func setupBrightnessSlider() {
        if let currentWhite = currentWhite {
            brightnessSlider.value = currentWhite.1
        }
    }

    private func updateGradientLayerFrame() {
        gradientLayer.frame = gradientView.bounds
    }
    
}

// Color change
extension WhiteGradientViewController {
    
    private func updateColorWithPosition(position: CGPoint, callOnWhiteSelection: Bool = true) {
        indicatorXPosition.constant = position.x
        indicatorYPosition.constant = position.y
        view.layoutIfNeeded()
        
        indicatorView.backgroundColor = currentColor
        colorView.backgroundColor = currentColor
        
        if callOnWhiteSelection {
            onWhiteSelection?(currentColor, (currentRatio, currentBrightness))
        }
    }
    
}

// Configuration
extension WhiteGradientViewController {
    
    func configureWithWhite(white: (Float, Float)?, onWhiteSelection: (UIColor, (Float, Float))->()) {
        self.currentWhite = white
        self.onWhiteSelection = onWhiteSelection
    }
    
}
