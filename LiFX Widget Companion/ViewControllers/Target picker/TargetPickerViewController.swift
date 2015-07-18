//
//  TargetPickerViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 04/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class TargetPickerViewController: UITableViewController {
    
    // Of LIFXLocation, LIFXGroup and LIFXLight
    var orderedTargets: [LIFXModel] = []
    var onSingleLightSelection: ((LIFXTargetable, String) -> ())?
    var isSingleLightSelectionMode: Bool {
        return onSingleLightSelection != nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// Configuration methods
extension TargetPickerViewController {
    
    func configureWithLights(lights: [LIFXLight], onSingleLightSelection: ((LIFXTargetable, String) -> ())?=nil) {
        self.onSingleLightSelection = onSingleLightSelection
        if self.isSingleLightSelectionMode {
            tableView.tableHeaderView = nil
        }
        
        for light in lights {
            if let locationIndex = find(orderedTargets, light.location) {
                // We already have the target and the group. Insert the light after the group.
                if let groupIndex = find(orderedTargets, light.group) {
                    orderedTargets.insert(light, atIndex: groupIndex + 1)
                    // We already have the location. Insert the group after the location, and the light after the group.
                } else {
                    orderedTargets.insert(light.group, atIndex: locationIndex + 1)
                    orderedTargets.insert(light, atIndex: locationIndex + 2)
                }
                // The location is new. Insert it, followed by the group, then the light.
            } else {
                orderedTargets.append(light.location)
                orderedTargets.append(light.group)
                orderedTargets.append(light)
            }
        }
        
        if !isSingleLightSelectionMode {
            selectIndexPathForSavedTargets()
        }
    }
    
    private func selectIndexPathForSavedTargets() {
        let savedTargets = SettingsPersistanceManager.sharedPersistanceManager.targets
        for (index, target) in enumerate(orderedTargets) {
            if let matchingTarget = modelWrapperForTarget(target) {
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)
            }
        }
    }
    
    private func modelWrapperForTarget(model: LIFXModel) -> TargetModelWrapper? {
        return SettingsPersistanceManager.sharedPersistanceManager.targets.filter {
            if let light = model as? LIFXLight {
                return light.identifier == $0.identifier
            }
            if let group = model as? LIFXBaseGroup {
                return group.identifier == $0.identifier
            }
            return false
        }.first
    }

}

// UITableViewDataSource, UITableViewDelegate
extension TargetPickerViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedTargets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TargetTableViewCell", forIndexPath: indexPath) as! TargetTableViewCell
        cell.configureWithModel(orderedTargets[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.selected == true {
            tableView.delegate?.tableView?(tableView, willDeselectRowAtIndexPath: indexPath)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            tableView.delegate?.tableView?(tableView, didDeselectRowAtIndexPath: indexPath)
            return nil
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let target = orderedTargets[indexPath.row]

        if isSingleLightSelectionMode {
            if let light = target as? LIFXLight {
                onSingleLightSelection?(light, light.label)
            }
            else if let group = target as? LIFXBaseGroup {
                onSingleLightSelection?(group, group.name)
            }
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            var targets = SettingsPersistanceManager.sharedPersistanceManager.targets
            if target is LIFXLight {
                targets.append(TargetModelWrapper(light: target as! LIFXLight))
            }
            else if target is LIFXBaseGroup {
                targets.append(TargetModelWrapper(group: target as! LIFXBaseGroup))
            }
            SettingsPersistanceManager.sharedPersistanceManager.targets = targets
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let target = orderedTargets[indexPath.row]
        
        if let matchingTarget = modelWrapperForTarget(target) {
            var targets = SettingsPersistanceManager.sharedPersistanceManager.targets
            targets.removeAtIndex(find(targets, matchingTarget)!)
            SettingsPersistanceManager.sharedPersistanceManager.targets = targets
        }
    }
    
}

// UIScrollViewDelegate
extension TargetPickerViewController {

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === tableView  && tableView.tableHeaderView != nil && decelerate == false {
            pinTableViewToHeader()
        }
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView === tableView && tableView.tableHeaderView != nil {
            pinTableViewToHeader()
        }
    }

    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === tableView && tableView.tableHeaderView != nil {
            let currentYPosition = tableView.contentOffset.y + tableView.contentInset.top
            let targetYPosition = targetContentOffset.memory.y + tableView.contentInset.top
            let headerHeight = CGRectGetHeight(tableView.tableHeaderView!.bounds)
            if currentYPosition > headerHeight && targetYPosition < headerHeight {
                targetContentOffset.memory.y = headerHeight - tableView.contentInset.top
            }
        }
    }

    private func pinTableViewToHeader() {
        var contentOffset = tableView.contentOffset
        let scrollPosition = contentOffset.y + tableView.contentInset.top
        let headerHeight = CGRectGetHeight(tableView.tableHeaderView!.bounds)
        if scrollPosition < headerHeight / 2 {
            contentOffset.y = 0
        }
        else if scrollPosition < headerHeight {
            contentOffset.y = headerHeight
        }
        else {
            return ;
        }
        contentOffset.y -= tableView.contentInset.top
        tableView.setContentOffset(contentOffset, animated: true)
    }
}
