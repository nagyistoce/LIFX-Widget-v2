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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// Configuration methods
extension TargetPickerViewController {
    
    func configureWithLights(lights: [LIFXLight]) {
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
    }
    
    private func selectIndexPathForSavedTargets() {
        /*
        ** 1. Get the saved targets
        ** 2. Loop over orderedLights
        ** 3. If the model identifier is in the saved targets, get its indexPath
        ** 4. Select all indexPaths
        */
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        ** 1. Add the light to the settings target
        ** 2. Tick the cell
        */
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        ** 1. Remove the light to the settings target
        ** 2. Untick the cell
        */
    }
    
}
