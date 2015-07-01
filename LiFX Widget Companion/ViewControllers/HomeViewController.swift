//
//  HomeViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 28/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var lights: [LIFXLight] = []

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !presentTutorialViewControllerIfNeeded() {
            fetchLights()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TutorialViewController" {
            configureTutorialViewController(segue.destinationViewController as! TutorialViewController)
        }
    }

}

// TutorialViewController
extension HomeViewController {

    private func presentTutorialViewControllerIfNeeded() -> Bool {
        if !SettingsPersistanceManager.sharedPersistanceManager.hasOAuthToken {
            performSegueWithIdentifier("TutorialViewController", sender: nil)
            return true
        }
        return false
    }

    private func configureTutorialViewController(tutorialViewController: TutorialViewController) {
        tutorialViewController.onValidation = { self.updateSettingsWithLights($0) }
    }
}

// Setup default values
extension HomeViewController {
    
    private func updateSettingsWithLights(lights: [LIFXLight]) {
        self.lights = lights
        
        let persistanceManager = SettingsPersistanceManager.sharedPersistanceManager
        // We want to have at leat 1 color or 1 intensity.
        if persistanceManager.colors.isEmpty && persistanceManager.intensities.isEmpty {
            persistanceManager.setDefaultColors()
            persistanceManager.setDefaultIntensities()
        }

        let targets = persistanceManager.targets
        if targets.isEmpty {
            persistanceManager.setDefaultTargetsWithLights(lights)
        } else {
            persistanceManager.targets = filterTargets(targets, withAvailableLights: lights)
        }
    }
    
    private func filterTargets(targets: [TargetModelWrapper], withAvailableLights lights: [LIFXLight]) -> [TargetModelWrapper] {
        var availableIdentifiers: [String] = []
        for light in lights {
            if !contains(availableIdentifiers, light.identifier) {
                availableIdentifiers.append(light.identifier)
            }
            if !contains(availableIdentifiers, light.location.identifier) {
                availableIdentifiers.append(light.location.identifier)
            }
            if !contains(availableIdentifiers, light.group.identifier) {
                availableIdentifiers.append(light.group.identifier)
            }
        }
        return targets.filter { contains(availableIdentifiers, $0.identifier) }
    }
}

// LIFX API Handling
extension HomeViewController {

    private func fetchLights() {
        let APIWrapper = LIFXAPIWrapper.sharedAPIWrapper()
        APIWrapper.setOAuthToken(SettingsPersistanceManager.sharedPersistanceManager.OAuthToken)

        APIWrapper.getAllLightsWithCompletion({ self.updateSettingsWithLights($0 as! [LIFXLight]) },
            onFailure: { error in
                self.displayAPIError(error)
            }
        )
    }

    private func displayAPIError(error: NSError) {
        if  LIFXAPIErrorCode.BadToken.rawValue == UInt(error.code) {
            UIAlertView(title: "Error", message: "LIFX API invalidated your token. Please generate a new one (\(error.localizedDescription))",
                delegate: nil, cancelButtonTitle: "Cancel").show()
            SettingsPersistanceManager.sharedPersistanceManager.OAuthToken = nil
            presentTutorialViewControllerIfNeeded()
        } else {
            UIAlertView(title: "Error", message: "LIFX API Responded with an error (\(error.code)): \(error.localizedDescription)",
            delegate: nil, cancelButtonTitle: "Cancel").show()
        }
    }

}

