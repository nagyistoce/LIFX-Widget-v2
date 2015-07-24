//
//  TodayViewController.swift
//  LiFXWidgetExtension
//
//  Created by Maxime de Chalendar on 23/07/2014.
//  Copyright (c) 2014 Maxime de Chalendar. All rights reserved.
//

import UIKit
import NotificationCenter

class ExtensionViewController: UIViewController {
    
    private lazy var targets = SettingsPersistanceManager.sharedPersistanceManager.targets
    private var selectedTarget: TargetModelWrapper? {
        if let selectedIndexPath = targetsCollectionView.indexPathsForSelectedItems().first as? NSIndexPath {
            return targets[selectedIndexPath.row]
        }
        return nil
    }
    @IBOutlet weak var targetsCollectionView: UICollectionView!
    @IBOutlet weak var targetsCollectionViewHeight: NSLayoutConstraint!
    
    private lazy var colors = SettingsPersistanceManager.sharedPersistanceManager.colors
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var powerStatusSwitch: UISwitch!
    @IBAction func powerStatusSwitchDidChangeValue(sender: UISwitch) {
        updateSelectedTargetPowerStatusIfPossible()
    }
    
    private var lights: [LIFXLight] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCollectionViewsHeights()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLIFXAPIWrapper()
        selectFirstTargetIfNeeded()
        updateTargetActionsViewsAvailability()
    }
    
}

extension ExtensionViewController: NCWidgetProviding {

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
}

extension ExtensionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == targetsCollectionView {
            return numberOfItemsInTargetCollectionView()
        }
        else if collectionView == colorsCollectionView {
            return numberOfItemsInColorsCollectionView()
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == targetsCollectionView {
            return targetsCollectionViewCellForItemAtIndexPath(indexPath)
        }
        else if collectionView == colorsCollectionView {
            return colorsCollectionViewCellForItemAtIndexPath(indexPath)
        }
        
        assertionFailure("collectionView isn't handeled")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets  {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let defaultInsets = flowLayout.sectionInset
        
        let width = realCollectionViewWidth
        let cellWidth = flowLayout.itemSize.width
        let spacingWidth = flowLayout.minimumInteritemSpacing
        
        let numberOfCells = self.collectionView(collectionView, numberOfItemsInSection: section)
        let numberOfSpaces = numberOfCells - 1
        
        var edgeInsets = (width - (cellWidth * CGFloat(numberOfCells) + spacingWidth * CGFloat(numberOfSpaces))) / 2.0
        edgeInsets = max(edgeInsets, 5)
        return UIEdgeInsetsMake(defaultInsets.top, edgeInsets, defaultInsets.bottom, edgeInsets)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == targetsCollectionView {
            targetsCollectionViewDidSelectItemAtIndexPath(indexPath)
        }
        else if collectionView == colorsCollectionView {
            colorsCollectionViewDidSelectItemAtIndexPath(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == targetsCollectionView {
            targetsCollectionViewDidDeselectItemAtIndexPath(indexPath)
        }
    }
    
}

extension ExtensionViewController /* TargetsCollectionViewDataSource */ {
    
    private func numberOfItemsInTargetCollectionView() -> Int {
        return targets.count
    }
    
    private func targetsCollectionViewCellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = targetsCollectionView.dequeueReusableCellWithReuseIdentifier("TargetCollectionViewCell", forIndexPath: indexPath) as! TargetCollectionViewCell
        cell.configureWithTarget(targets[indexPath.row])
        return cell
    }
    
    private func targetsCollectionViewDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
        powerStatusSwitch.setOn(getPowerStatusForLightIdentifier(targets[indexPath.row].identifier), animated: true)
        updateTargetActionsViewsAvailability()
    }
    
    private func targetsCollectionViewDidDeselectItemAtIndexPath(indexPath: NSIndexPath) {
        updateTargetActionsViewsAvailability()
    }
    
}

extension ExtensionViewController /* ColorsCollectionViewCell */ {
    
    private func numberOfItemsInColorsCollectionView() -> Int {
        return colors.count
    }
    
    private func colorsCollectionViewCellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = colorsCollectionView.dequeueReusableCellWithReuseIdentifier("ColorCollectionViewCell", forIndexPath: indexPath) as! ColorCollectionViewCell
        cell.configureWithColor(colors[indexPath.row])
        return cell
    }
    
    private func colorsCollectionViewDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
        if let selectedTarget = selectedTarget {
            let selectedColor = colors[indexPath.row]
            LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(selectedColor.toTargetUpdate(), toTarget: selectedTarget, onCompletion: nil, onFailure: nil)
        }
    }
    
}

extension ExtensionViewController /* Updating UI */ {
    
    private func updateCollectionViewsHeights() {
        targetsCollectionViewHeight.constant = targetsCollectionView.contentSize.height
        colorsCollectionViewHeight.constant = colorsCollectionView.contentSize.height
        view.layoutIfNeeded()
    }
    
    private func selectFirstTargetIfNeeded() {
        if targets.count == 1 {
            let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            targetsCollectionView.selectItemAtIndexPath(firstIndexPath, animated: false, scrollPosition: .None)
            targetsCollectionViewDidSelectItemAtIndexPath(firstIndexPath)
        }
    }
    
    private func updateTargetActionsViewsAvailability() {
        if selectedTarget == nil {
            powerStatusSwitch.enabled = false
            powerStatusSwitch.on = false
            colorsCollectionView.userInteractionEnabled = false
            colorsCollectionView.alpha = 0.5
            if let selectedIndexPaths = colorsCollectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
                for indexPath in selectedIndexPaths {
                    colorsCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
                }
            }
        }
        else {
            powerStatusSwitch.enabled = true
            colorsCollectionView.userInteractionEnabled = true
            colorsCollectionView.alpha = 1
        }
    }
    
    private func updateSelectedTargetPowerStatusIfPossible() {
        if let selectedTarget = selectedTarget {
            let powerStatus = powerStatusSwitch.on
            LIFXAPIWrapper.sharedAPIWrapper().changeLightPowerStatus(powerStatus, ofTarget: selectedTarget, onCompletion: { _ in
                self.setPowerStatus(powerStatus, forLightIdentifier: selectedTarget.identifier)
            }, onFailure: nil)
        }
    }
    
    private func updateViewForUnconfiguredOAuthToken() {
        // TODO
    }
}

extension ExtensionViewController /* LIFX API Wrapper */ {
    
    private func setupLIFXAPIWrapper() {
        if let OAuthToken = SettingsPersistanceManager.sharedPersistanceManager.OAuthToken {
            LIFXAPIWrapper.sharedAPIWrapper().setOAuthToken(OAuthToken)
            LIFXAPIWrapper.sharedAPIWrapper().getAllLightsWithCompletion({
                    self.lights = $0 as! [LIFXLight]
                },
                onFailure: { error in
                    if  LIFXAPIErrorCode.BadToken.rawValue == UInt(error.code) {
                        self.updateViewForUnconfiguredOAuthToken()
                    }
                }
            )
        }
        else {
            updateViewForUnconfiguredOAuthToken()
        }
    }
    
    private func getPowerStatusForLightIdentifier(identifier: String) -> Bool {
        let light = self.lights.filter { $0.identifier == identifier }.first
        return light?.connected == true && light?.on == true
    }
    
    private func setPowerStatus(powerStatus: Bool, forLightIdentifier identifier: String) {
        if let light = (self.lights.filter { $0.identifier == identifier }.first) {
            light.on = powerStatus
        }
    }
    
}

extension ExtensionViewController /* Apple SDK's Fixes */ {
    
    // FIXME: Apple's SDK Bug
    /*
    ** On regular horizontal size classes, the notification center
    ** has a constant width with left and right margins. For some
    ** reason, the width of the collectionView is the same as the
    ** screen's width, as if there were no margins.
    */
    private var realCollectionViewWidth: CGFloat {
        get {
            switch (traitCollection.horizontalSizeClass, traitCollection.userInterfaceIdiom) {
            case (.Regular, .Pad):
                return 592
            case (.Regular, .Phone):
                return 399
            default:
                return CGRectGetWidth(view.bounds)
            }
        }
    }
    
}

