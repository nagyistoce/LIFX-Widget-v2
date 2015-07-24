//
//  TargetActionInterfaceController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 30/01/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import WatchKit
import Foundation

class TargetActionInterfaceController: WKInterfaceController {

    private lazy var colors = SettingsPersistanceManager.sharedPersistanceManager.colors
    @IBOutlet private weak var colorsTable: WKInterfaceTable!

    private lazy var intensities = SettingsPersistanceManager.sharedPersistanceManager.intensities
    @IBOutlet private weak var intensitiesTable: WKInterfaceTable!

    @IBOutlet private weak var powerStatusSwitch: WKInterfaceSwitch!
    private var powerStatus = false
    @IBAction func powerStatusSwitchChangedValue(value: Bool) {
        powerStatus = value
        updateToogleTitle()
        updateSelectedLightPowerStatusWithCurrentSwitchPosition()
    }

    private var selectedTarget: TargetModelWrapper?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        selectedTarget = context?["target"] as? TargetModelWrapper
        powerStatusSwitchChangedValue(context?["powerStatus"] as? Bool ?? false)
        powerStatusSwitch.setOn(powerStatus)
        updateToogleTitle()
        configureColorsTable()
        configureIntensitiesTable()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if table == colorsTable {
            colorsTableDidSelectRowAtIndex(rowIndex)
        }
        else if table == intensitiesTable {
            intensitiesTableDidSelectRowAtIndex(rowIndex)
        }
    }
    
}

extension TargetActionInterfaceController /* Colors Table */ {
    
    private func configureColorsTable() {
        colorsTable.setNumberOfRows(colors.count, withRowType: "ColorRowController")
        for (index, color) in enumerate(colors) {
            let rowController = colorsTable.rowControllerAtIndex(index) as! ColorRowController
            rowController.configureWithColor(color)
        }
    }
    
    
    private func colorsTableDidSelectRowAtIndex(index: Int) {
        if let selectedTarget = selectedTarget {
            let selectedColor = colors[index]
            LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(selectedColor.toTargetUpdate(), toTarget: selectedTarget, onCompletion: nil, onFailure: nil)
            powerStatusSwitch.setOn(true)
            powerStatusSwitchChangedValue(true)
        }
    }
    
}

extension TargetActionInterfaceController /* Intensities Table */ {
    
    private func configureIntensitiesTable() {
        intensitiesTable.setNumberOfRows(intensities.count, withRowType: "IntensityRowController")
        for (index, intensity) in enumerate(intensities) {
            let rowController = intensitiesTable.rowControllerAtIndex(index) as! IntensityRowController
            rowController.configureWithIntensity(intensity)
        }
    }
    
    private func intensitiesTableDidSelectRowAtIndex(index: Int) {
        if let selectedTarget = selectedTarget {
            let selectedIntensity = intensities[index]
            LIFXAPIWrapper.sharedAPIWrapper().applyUpdate(selectedIntensity.toTargetUpdate(), toTarget: selectedTarget, onCompletion: nil, onFailure: nil)
            powerStatusSwitch.setOn(true)
            powerStatusSwitchChangedValue(true)
        }
    }
    
}

extension TargetActionInterfaceController /* Power status switch */ {
    
    private func updateSelectedLightPowerStatusWithCurrentSwitchPosition() {
        if let selectedTarget = selectedTarget {
            LIFXAPIWrapper.sharedAPIWrapper().changeLightPowerStatus(powerStatus, ofTarget: selectedTarget, onCompletion: nil, onFailure: nil)
        }
    }
    
    func updateToogleTitle() {
        let defaultFont = UIFont.systemFontOfSize(12)
        let boldFont = UIFont.boldSystemFontOfSize(12)
        
        var onString: NSAttributedString!
        var offString: NSAttributedString!
        if powerStatus {
            onString = NSAttributedString(string: "On", attributes: [NSFontAttributeName: boldFont])
            offString = NSAttributedString(string: " / Off", attributes: [NSFontAttributeName: defaultFont])
        }
        else {
            onString = NSAttributedString(string: "On / ", attributes: [NSFontAttributeName: defaultFont])
            offString = NSAttributedString(string: "Off", attributes: [NSFontAttributeName: boldFont])
        }
        
        var mutableString = NSMutableAttributedString()
        mutableString.appendAttributedString(onString)
        mutableString.appendAttributedString(offString)
        powerStatusSwitch.setAttributedTitle(mutableString)
    }
    
}

