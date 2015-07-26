//
//  TodayViewController.swift
//  LiFXWidgetExtension
//
//  Created by Maxime de Chalendar on 23/07/2014.
//  Copyright (c) 2014 Maxime de Chalendar. All rights reserved.
//

import UIKit
import NotificationCenter

class LIFXWidgetViewController: UIViewController {
    
    private lazy var targets = SettingsPersistanceManager.sharedPersistanceManager.targets
    private var selectedTarget: TargetModelWrapper? {
        if let selectedIndexPath = targetsCollectionView.indexPathsForSelectedItems().first as? NSIndexPath {
            return targets[selectedIndexPath.row]
        }
        return nil
    }
    @IBOutlet private weak var targetsCollectionView: UICollectionView!
    @IBOutlet private weak var targetsCollectionViewHeight: NSLayoutConstraint!
    
    private lazy var colors = SettingsPersistanceManager.sharedPersistanceManager.colors
    @IBOutlet private weak var colorsCollectionView: UICollectionView!
    @IBOutlet private weak var colorsCollectionViewHeight: NSLayoutConstraint!
    
    private lazy var intensities = SettingsPersistanceManager.sharedPersistanceManager.intensities
    @IBOutlet private weak var intensitiesCollectionView: UICollectionView!
    @IBOutlet private weak var intensitiesCollectionViewHeight: NSLayoutConstraint!
    
    private lazy var scenes = SettingsPersistanceManager.sharedPersistanceManager.scenes
    @IBOutlet private weak var scenesCollectionView: UICollectionView!
    @IBOutlet private weak var scenesCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var powerStatusSwitch: UISwitch!
    @IBAction func powerStatusSwitchDidChangeValue(sender: UISwitch) {
        updateSelectedTargetPowerStatusIfPossible()
    }
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func tappedErrorView(sender: UITapGestureRecognizer) {
        if let companionURL = NSURL(string: "LIFXWidgetCompanion://") {
            extensionContext?.openURL(companionURL, completionHandler: nil)
        }
    }

    private var lights: [LIFXLight] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCollectionViewsHeights()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setupLIFXAPIWrapper() {
            setupEmptyViewIfNeeded()
            selectFirstTargetIfNeeded()
            updateTargetActionsViewsAvailability()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for collectionView in [targetsCollectionView, colorsCollectionView, intensitiesCollectionView, scenesCollectionView] {
            collectionView.reloadData()
        }
    }
    
}

extension LIFXWidgetViewController: NCWidgetProviding {

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
}

extension LIFXWidgetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == targetsCollectionView {
            return numberOfItemsInTargetCollectionView()
        }
        else if collectionView == colorsCollectionView {
            return numberOfItemsInColorsCollectionView()
        }
        else if collectionView == intensitiesCollectionView {
            return numberOfItemsInIntensitiesCollectionView()
        }
        else if collectionView == scenesCollectionView {
            return numberOfItemsInScenesCollectionView()
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
        else if collectionView == intensitiesCollectionView {
            return intensitiesCollectionViewCellForItemAtIndexPath(indexPath)
        }
        else if collectionView == scenesCollectionView {
            return scenesCollectionViewCellForItemAtIndexPath(indexPath)
        }
        
        assertionFailure("collectionView isn't handeled")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets  {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let defaultInsets = flowLayout.sectionInset
        
        let width = CGRectGetWidth(view.bounds)
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
        else if collectionView == intensitiesCollectionView {
            intensitiesCollectionViewDidSelectItemAtIndexPath(indexPath)
        }
        else if collectionView == scenesCollectionView {
            scenesCollectionViewDidSelectItemAtIndexPath(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == targetsCollectionView {
            targetsCollectionViewDidDeselectItemAtIndexPath(indexPath)
        }
    }
    
}

extension LIFXWidgetViewController /* TargetsCollectionViewDataSource */ {
    
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
        
        if let selectedSceneIndexPath = scenesCollectionView.indexPathsForSelectedItems().first as? NSIndexPath {
            scenesCollectionView.deselectItemAtIndexPath(selectedSceneIndexPath, animated: true)
        }
    }
    
    private func targetsCollectionViewDidDeselectItemAtIndexPath(indexPath: NSIndexPath) {
        updateTargetActionsViewsAvailability()
    }
    
}

extension LIFXWidgetViewController /* ColorsCollectionViewCell */ {
    
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
            LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(selectedColor.toTargetUpdate(), toTarget: selectedTarget, onCompletion: nil, onFailure: {
                self.updateViewForError($0)
            })
        }
    }
    
}

extension LIFXWidgetViewController /* IntensitiesCollectionView */ {
    
    private func numberOfItemsInIntensitiesCollectionView() -> Int {
        return intensities.count
    }
    
    private func intensitiesCollectionViewCellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = intensitiesCollectionView.dequeueReusableCellWithReuseIdentifier("IntensityCollectionViewCell", forIndexPath: indexPath) as! IntensityCollectionViewCell
        cell.configureWithIntensity(intensities[indexPath.row])
        return cell
    }
    
    private func intensitiesCollectionViewDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
        if let selectedTarget = selectedTarget {
            let selectedIntensity = intensities[indexPath.row]
            LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(selectedIntensity.toTargetUpdate(), toTarget: selectedTarget, onCompletion: nil, onFailure: {
                self.updateViewForError($0)
            })
        }
    }
    
}

extension LIFXWidgetViewController /* ScenesCollectionView */ {
    
    private func numberOfItemsInScenesCollectionView() -> Int {
        return scenes.count
    }
    
    private func scenesCollectionViewCellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = scenesCollectionView.dequeueReusableCellWithReuseIdentifier("SceneCollectionViewCell", forIndexPath: indexPath) as! SceneCollectionViewCell
        cell.configureWithScene(scenes[indexPath.row])
        return cell
    }
    
    private func scenesCollectionViewDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
        if let selectedTargetIndexPath = targetsCollectionView.indexPathsForSelectedItems().first as? NSIndexPath {
            targetsCollectionView.deselectItemAtIndexPath(selectedTargetIndexPath, animated: true)
            targetsCollectionViewDidDeselectItemAtIndexPath(selectedTargetIndexPath)
        }
        
        let selectedScene = scenes[indexPath.row]
        LIFXAPIWrapper.sharedAPIWrapper().applyScene(selectedScene.scene, onCompletion: nil, onFailure: {
            self.updateViewForError($0)
        })
    }
    
}

extension LIFXWidgetViewController /* Updating UI */ {
    
    private func updateCollectionViewsHeights() {
        let heightsBindings = [ (targetsCollectionViewHeight, targetsCollectionView),
            (colorsCollectionViewHeight, colorsCollectionView),
            (intensitiesCollectionViewHeight, intensitiesCollectionView),
            (scenesCollectionViewHeight, scenesCollectionView)
        ]
        for (constraint, collectionView) in heightsBindings {
            constraint.constant = collectionView.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
    private func setupEmptyViewIfNeeded() {
        if targets.isEmpty {
            updateViewWithErrorTitle("Please add at least a target in the companion app")
        }
        else if colors.isEmpty && intensities.isEmpty {
            updateViewWithErrorTitle("Please add at least a colour or an intensity")
        }
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
            for collectionView in [colorsCollectionView, intensitiesCollectionView] {
                collectionView.userInteractionEnabled = false
                collectionView.alpha = 0.5
                if let selectedIndexPaths = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
                    for indexPath in selectedIndexPaths {
                        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                    }
                }
            }
        }
        else {
            powerStatusSwitch.enabled = true
            for collectionView in [colorsCollectionView, intensitiesCollectionView] {
                collectionView.userInteractionEnabled = true
                collectionView.alpha = 1
            }
        }
    }
    
    private func updateSelectedTargetPowerStatusIfPossible() {
        if let selectedTarget = selectedTarget {
            let powerStatus = powerStatusSwitch.on
            LIFXAPIWrapper.sharedAPIWrapper().changeLightPowerStatus(powerStatus, ofTarget: selectedTarget,
                onCompletion: { _ in
                    self.setPowerStatus(powerStatus, forLightIdentifier: selectedTarget.identifier)
                }, onFailure: {
                    self.updateViewForError($0)
            })
        }
    }
    
    private func updateViewForError(error: NSError) {
        if  LIFXAPIErrorCode.BadToken.rawValue == UInt(error.code) {
            self.updateViewForUnconfiguredOAuthToken()
        }
    }
    
    private func updateViewForUnconfiguredOAuthToken() {
        updateViewWithErrorTitle("Please configure LIFX Cloud")
    }
    
    private func updateViewWithErrorTitle(error: String) {
        mainView.hidden = true
        errorLabel.text = error.uppercaseString
        errorView.hidden = false
    }
}

extension LIFXWidgetViewController /* LIFX API Wrapper */ {
    
    private func setupLIFXAPIWrapper() -> Bool {
        if let OAuthToken = SettingsPersistanceManager.sharedPersistanceManager.OAuthToken {
            LIFXAPIWrapper.sharedAPIWrapper().setOAuthToken(OAuthToken)
            LIFXAPIWrapper.sharedAPIWrapper().getAllLightsWithCompletion({
                    self.lights = $0 as! [LIFXLight]
                },
                onFailure: {
                    self.updateViewForError($0)
                }
            )
            return true
        }
        else {
            updateViewForUnconfiguredOAuthToken()
            return false
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
