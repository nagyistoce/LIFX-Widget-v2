//
//  ColorsListViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//
import UIKit

class ColorsListViewController: UITableViewController {
    
    private var feedbackLights: [LIFXLight] = []
    private lazy var colors: [UIColor] = {
        return SettingsPersistanceManager.sharedPersistanceManager.colors.map {
            return UIColor(hue: CGFloat($0.hue) / 360, saturation: $0.saturation, brightness: $0.brightness, alpha: 1)
        }
    }()
    
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
        else if (segue.identifier == "TargetPickerViewController") {
            configureTargetPickerViewController(segue.destinationViewController as! TargetPickerViewController)
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
    
}

// UIScrollViewDelegate
extension ColorsListViewController {
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === tableView && decelerate == false {
            pinTableViewToHeader()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView === tableView {
            pinTableViewToHeader()
        }
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === tableView {
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

// ColorPickerViewController
extension ColorsListViewController {

    private func configureColorPickerViewController(colorPickerViewController: ColorPickerViewController) {
        colorPickerViewController.configureWithBaseColor(nil, feedbackLights: feedbackLights) { self.saveColor($0) }
    }
    
    private func configureColorPickerViewControllerWithSelectedColor(colorPickerViewController: ColorPickerViewController) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            let selectedColor = colors[selectedIndexPath.row]
            colorPickerViewController.configureWithBaseColor(selectedColor, feedbackLights: feedbackLights) { self.replaceColorAtIndexPath(selectedIndexPath, withColor: $0) }
        }

    }
    
    private func replaceColorAtIndexPath(indexPath: NSIndexPath, withColor newColor: UIColor) {
        if let targetOperation = targetOperationFromColor(newColor) {
            
            var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
            savedColors.removeAtIndex(indexPath.row)
            savedColors.insert(targetOperation, atIndex: indexPath.row)
            SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors

            colors.removeAtIndex(indexPath.row)
            colors.insert(newColor, atIndex: indexPath.row)
            tableView.reloadData()
        }
    }
    
    private func saveColor(color: UIColor) {
        if let targetOperation = targetOperationFromColor(color) {
            
            var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
            savedColors.append(targetOperation)
            SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors
            
            colors.append(color)
            tableView.reloadData()
            delay(0.01) {
                let lastIndexPath = NSIndexPath(forRow: self.tableView(self.tableView, numberOfRowsInSection: 0) - 1, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    private func targetOperationFromColor(color: UIColor) -> LIFXTargetOperationUpdate? {
        if let (hue, saturation, brightness, _) = color.HSBAComponents() {
            let update = LIFXTargetOperationUpdate(brightness: brightness)
            update.hue = UInt(hue * 360)
            update.saturation = saturation
            return update
        }
        return nil
    }
    
}

// TargetPickerViewController
extension ColorsListViewController {
    private func configureTargetPickerViewController(targetPickerViewController: TargetPickerViewController) {
        targetPickerViewController.configureWithLights(feedbackLights)
        
    }
}

