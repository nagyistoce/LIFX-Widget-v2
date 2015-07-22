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