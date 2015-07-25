//
//  ColorsListViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//
import UIKit

class ColorsListViewController: HeaderTableViewController {
    
    private var feedbackLights: [LIFXLight] = []
    private lazy var colors = SettingsPersistanceManager.sharedPersistanceManager.colors
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ColorPickerViewController_New" {
            configureColorPickerViewController(segue.destinationViewController as! ColorPickerViewController)
        }
        else if (segue.identifier == "ColorPickerViewController_Update") {
            configureColorPickerViewControllerWithSelectedColor(segue.destinationViewController as! ColorPickerViewController)
        }
    }

}

// Configuration methods
extension ColorsListViewController {

    func configureWithFeedbackLights(lights: [LIFXLight]) {
        feedbackLights = lights
    }
    
}

// UITableViewDataSource, UITableViewDelegate
extension ColorsListViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorTableViewCell", forIndexPath: indexPath) as! ColorTableViewCell
        cell.configureWithColor(colors[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
            savedColors.removeAtIndex(indexPath.row)
            SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors
            colors.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}

// ColorPickerViewController
extension ColorsListViewController {

    private func configureColorPickerViewController(colorPickerViewController: ColorPickerViewController) {
        colorPickerViewController.configureWithBaseColor(nil, feedbackLights: feedbackLights) { color in
            self.saveColor(color)
        }
    }
    
    private func configureColorPickerViewControllerWithSelectedColor(colorPickerViewController: ColorPickerViewController) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            let selectedColor = colors[selectedIndexPath.row]
            colorPickerViewController.configureWithBaseColor(selectedColor.copy() as? ColorModelWrapper, feedbackLights: feedbackLights) { color in
                self.replaceColorAtIndexPath(selectedIndexPath, withColor: color)
            }
        }
    }
    
    private func saveColor(color: ColorModelWrapper) {
        var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
        savedColors.append(color)
        SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors
        
        colors.append(color)
        tableView.reloadData()
        delay(0.01) {
            let lastIndexPath = NSIndexPath(forRow: self.tableView(self.tableView, numberOfRowsInSection: 0) - 1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    private func replaceColorAtIndexPath(indexPath: NSIndexPath, withColor newColor: ColorModelWrapper) {
        var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
        savedColors.removeAtIndex(indexPath.row)
        savedColors.insert(newColor, atIndex: indexPath.row)
        SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors

        colors.removeAtIndex(indexPath.row)
        colors.insert(newColor, atIndex: indexPath.row)
        tableView.reloadData()
    }
    
}
