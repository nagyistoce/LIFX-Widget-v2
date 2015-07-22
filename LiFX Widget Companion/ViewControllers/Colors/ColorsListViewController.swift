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
    private lazy var colors: [UIColor] = {
        return SettingsPersistanceManager.sharedPersistanceManager.colors.map { operation in
            if operation.kelvin > 0 {
                return UIColor(kelvionRatio: rawKelvinToRatio(operation.kelvin))
            }
            else {
                return UIColor(hue: CGFloat(operation.hue) / 360, saturation: operation.saturation, brightness: operation.brightness, alpha: 1)
            }
        }
    }()
    private lazy var whiteRatios: [(Float, Float)?] = {
        return SettingsPersistanceManager.sharedPersistanceManager.colors.map {
            if $0.kelvin == 0 {
                return nil
            }
            else {
                return (rawKelvinToRatio($0.kelvin), Float($0.brightness))
            }
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

// ColorPickerViewController
extension ColorsListViewController {

    private func configureColorPickerViewController(colorPickerViewController: ColorPickerViewController) {
        colorPickerViewController.configureWithBaseColor(nil, feedbackLights: feedbackLights) { color, white in
            self.saveColor(color, white: white)
        }
    }
    
    private func configureColorPickerViewControllerWithSelectedColor(colorPickerViewController: ColorPickerViewController) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            if let selectedWhiteRatio = whiteRatios[selectedIndexPath.row] {
                colorPickerViewController.configureWithBaseWhiteRatio(selectedWhiteRatio, feedbackLights: feedbackLights) { color, white in
                    self.replaceColorAtIndexPath(selectedIndexPath, withColor: color, white: white)
                }
            }
            else {
                let selectedColor = colors[selectedIndexPath.row]
                colorPickerViewController.configureWithBaseColor(selectedColor, feedbackLights: feedbackLights) { color, white in
                    self.replaceColorAtIndexPath(selectedIndexPath, withColor: color, white: white)
                }
            }
        }

    }
    
    private func replaceColorAtIndexPath(indexPath: NSIndexPath, withColor newColor: UIColor, white: (Float, Float)?) {
        if let targetOperation = targetOperationFromColor(newColor, white: white) {
            
            var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
            savedColors.removeAtIndex(indexPath.row)
            savedColors.insert(targetOperation, atIndex: indexPath.row)
            SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors

            colors.removeAtIndex(indexPath.row)
            colors.insert(newColor, atIndex: indexPath.row)
            whiteRatios.removeAtIndex(indexPath.row)
            whiteRatios.insert(white, atIndex: indexPath.row)
            tableView.reloadData()
        }
    }
    
    private func saveColor(color: UIColor, white: (Float, Float)?) {
        if let targetOperation = targetOperationFromColor(color, white: white) {
            
            var savedColors = SettingsPersistanceManager.sharedPersistanceManager.colors
            savedColors.append(targetOperation)
            SettingsPersistanceManager.sharedPersistanceManager.colors = savedColors
            
            colors.append(color)
            whiteRatios.append(white)
            tableView.reloadData()
            delay(0.01) {
                let lastIndexPath = NSIndexPath(forRow: self.tableView(self.tableView, numberOfRowsInSection: 0) - 1, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    private func targetOperationFromColor(color: UIColor, white: (Float, Float)?) -> LIFXTargetOperationUpdate? {
        if let white = white, let (hue, saturation, brightness, _) = color.HSBAComponents() {
            let update = LIFXTargetOperationUpdate(kelvin: ratioToRawKelvin(white.0))
            update?.brightness = CGFloat(white.1)
            update.hue = UInt(hue)
            update.saturation = saturation
            return update
        }
        
        if let (hue, saturation, brightness, _) = color.HSBAComponents() {
            let update = LIFXTargetOperationUpdate(brightness: brightness)
            update.hue = UInt(hue * 360)
            update.saturation = saturation
            return update
        }
        
        return nil
    }
    
}

