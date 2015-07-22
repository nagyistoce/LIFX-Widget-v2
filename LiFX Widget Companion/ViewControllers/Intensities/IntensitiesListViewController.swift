//
//  IntensitiesListViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 22/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class IntensitiesListViewController: HeaderTableViewController {
    
    private var feedbackLights: [LIFXLight] = []
    private lazy var intensities = SettingsPersistanceManager.sharedPersistanceManager.intensities
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "IntensityPickerViewController_New" {
            configureIntensityPickerViewController(segue.destinationViewController as! IntensityPickerViewController)
        }
        else if (segue.identifier == "IntensityPickerViewController_Update") {
            configureIntensityPickerViewControllerWithSelectedIntensity(segue.destinationViewController as! IntensityPickerViewController)
        }
    }
    
}

// Configuration methods
extension IntensitiesListViewController {
    
    func configureWithFeedbackLights(lights: [LIFXLight]) {
        feedbackLights = lights
    }
    
}

// UITableViewDataSource, UITableViewDelegate
extension IntensitiesListViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intensities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IntensityTableViewCell", forIndexPath: indexPath) as! IntensityTableViewCell
        cell.configureWithIntensity(intensities[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var savedIntensities = SettingsPersistanceManager.sharedPersistanceManager.intensities
            savedIntensities.removeAtIndex(indexPath.row)
            SettingsPersistanceManager.sharedPersistanceManager.intensities = savedIntensities
            intensities.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}

// ColorPickerViewController
extension IntensitiesListViewController {
    
    private func configureIntensityPickerViewController(intensityPicker: IntensityPickerViewController) {
        intensityPicker.configureWithBaseIntensity(nil, feedbackLights: feedbackLights) { self.saveIntensity($0) }
    }
    
    private func configureIntensityPickerViewControllerWithSelectedIntensity(intensityPicker: IntensityPickerViewController) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            let intensity = intensities[selectedIndexPath.row]
            intensityPicker.configureWithBaseIntensity(intensity, feedbackLights: feedbackLights) { self.replaceIntensityAtIndexPath(selectedIndexPath, withIntensity: $0) }
        }
    }

    private func saveIntensity(intensity: IntensityModelWrapper) {
        var savedIntensities = SettingsPersistanceManager.sharedPersistanceManager.intensities
        savedIntensities.append(intensity)
        SettingsPersistanceManager.sharedPersistanceManager.intensities = savedIntensities

        intensities.append(intensity)
        tableView.reloadData()
        delay(0.01) {
            let lastIndexPath = NSIndexPath(forRow: self.tableView(self.tableView, numberOfRowsInSection: 0) - 1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    private func replaceIntensityAtIndexPath(indexPath: NSIndexPath, withIntensity newIntensity: IntensityModelWrapper) {
        var savedIntensities = SettingsPersistanceManager.sharedPersistanceManager.intensities
        savedIntensities.removeAtIndex(indexPath.row)
        savedIntensities.insert(newIntensity, atIndex: indexPath.row)
        SettingsPersistanceManager.sharedPersistanceManager.intensities = savedIntensities
        
        intensities.removeAtIndex(indexPath.row)
        intensities.insert(newIntensity, atIndex: indexPath.row)
        tableView.reloadData()
    }

}