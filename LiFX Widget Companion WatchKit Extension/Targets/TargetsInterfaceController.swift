//
//  TargetsInterfaceController.swift
//  LiFX Widget Companion WatchKit Extension
//
//  Created by Maxime de Chalendar on 30/01/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import WatchKit
import Foundation


class TargetsInterfaceController: WKInterfaceController {
    
    private var lights: [LIFXLight] = []
    private lazy var targets = SettingsPersistanceManager.sharedPersistanceManager.targets
    @IBOutlet private weak var targetsTable: WKInterfaceTable!
    
    override func willActivate() {
        super.willActivate()
        
        if !presentConfigurationAlertIfNeeded() {
            setupLIFXAPI()
            setupTargetsTable()
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let selectedTarget = targets[rowIndex]
        pushControllerWithName("TargetActionInterfaceController", context: [
            "target": selectedTarget,
            "powerStatus": getPowerStatusForTargetWithIdentifier(selectedTarget.identifier)
        ])
    }
    
}

extension TargetsInterfaceController /* Targets Table */ {
    
    private func setupTargetsTable() {
        targetsTable.setNumberOfRows(targets.count, withRowType: "TargetRowController")
        for (index, target) in enumerate(targets) {
            let rowController = targetsTable.rowControllerAtIndex(index) as! TargetRowController
            rowController.configureWithTarget(target)
        }
    }
    
}

extension TargetsInterfaceController /* Configuration Alert */ {
    
    private func presentConfigurationAlertIfNeeded() -> Bool {
        if targets.isEmpty {
            AlertInterfaceController.presentOnController(self,
                title: "Configuration",
                content: "Please add at least a target in the companion app",
                cancelTitle: "Reload",
                onCancellation: nil)
            return true
        }
        else if SettingsPersistanceManager.sharedPersistanceManager.colors.isEmpty
            && SettingsPersistanceManager.sharedPersistanceManager.intensities.isEmpty {
                AlertInterfaceController.presentOnController(self,
                    title: "Configuration",
                    content: "Please add at least a colour or an intensity in the companion app",
                    cancelTitle: "Reload",
                    onCancellation: nil)
                return true
        }
        return false
    }
}

extension TargetsInterfaceController /* LIFX API */ {
    
    private func setupLIFXAPI() {
        if let OAuthToken = SettingsPersistanceManager.sharedPersistanceManager.OAuthToken {
            LIFXAPIWrapper.sharedAPIWrapper().setOAuthToken(OAuthToken)
            LIFXAPIWrapper.sharedAPIWrapper().getAllLightsWithCompletion({
                    self.lights = $0 as! [LIFXLight]
                },
                onFailure: { error in
                    if LIFXAPIErrorCode.BadToken.rawValue == UInt(error.code) {
                        self.displayOAuthTokenFailure()
                    }
                }
            )
        }
        else {
            displayOAuthTokenFailure()
        }
    }
    
    private func displayOAuthTokenFailure() {
        AlertInterfaceController.presentOnController(self,
            title: "LIFX Cloud",
            content: "Please configure LIFX Cloud in the companion app",
            cancelTitle: "Reload",
            onCancellation: nil)
    }
    
    private func getPowerStatusForTargetWithIdentifier(identifier: String) -> Bool {
        let light = self.lights.filter { $0.identifier == identifier }.first
        return light?.connected == true && light?.on == true
    }
}
