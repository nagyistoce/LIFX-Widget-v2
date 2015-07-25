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
    var scenes: [LIFXScene] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !presentTutorialViewControllerIfNeeded() {
            if lights.isEmpty && scenes.isEmpty {
                fetchLightsAndScenes() { lights, scenes in
                    self.updateSettingsWithLights(lights)
                    self.updateSettingsWithScenes(scenes)
                }
            }
        }
        configureDefaultColorsAndIntensities()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "ScenesTableViewController" {
            if scenes.isEmpty {
                UIAlertView(title: "Scenes", message: "Please configure scenes in the official LIFX application", delegate: nil, cancelButtonTitle: "Cancel").show()
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TutorialViewController" {
            configureTutorialViewController(segue.destinationViewController as! TutorialViewController)
        }
        else if segue.identifier == "TargetPickerViewController" {
            configureTargetPickerViewController(segue.destinationViewController as! TargetPickerViewController)
        }
        else if segue.identifier == "ColorsListViewController" {
            configureColorsListViewController(segue.destinationViewController as! ColorsListViewController)
        }
        else if segue.identifier == "IntensityPickerViewController" {
            configureIntensitiesListViewController(segue.destinationViewController as! IntensitiesListViewController)
        }
        else if segue.identifier == "ScenesTableViewController" {
            configureScenesListViewController(segue.destinationViewController as! ScenesTableViewController)
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
        tutorialViewController.onValidation = { lights in
            if lights.isEmpty {
                self.fetchLightsAndScenes { lights, scenes in
                    self.updateSettingsWithLights(lights)
                    self.updateSettingsWithScenes(scenes)
                }
            }
            else {
                self.updateSettingsWithLights(lights)
                self.fetchScenes {
                    self.updateSettingsWithScenes($0)
                }
            }
        }
    }
}

// TargetPickerViewController
extension HomeViewController {
    
    private func configureTargetPickerViewController(targetPickerViewController: TargetPickerViewController) {
        targetPickerViewController.configureWithLights(lights)
    }
    
}

// ColorsListViewController
extension HomeViewController {
    
    private func configureColorsListViewController(colorsListViewController: ColorsListViewController) {
        colorsListViewController.configureWithFeedbackLights(lights)
    }
}

// IntensitiesViewController
extension HomeViewController {
    
    private func configureIntensitiesListViewController(intensitiesViewController: IntensitiesListViewController) {
        intensitiesViewController.configureWithFeedbackLights(lights)
    }
    
}

// ScenesTableViewController
extension HomeViewController {
    
    private func configureScenesListViewController(scenesViewController: ScenesTableViewController) {
        scenesViewController.configureWithScenes(scenes)
    }
}

// Setup default values
extension HomeViewController {
    
    private func updateSettingsWithLights(lights: [LIFXLight]) {
        self.lights = lights
        
        let persistanceManager = SettingsPersistanceManager.sharedPersistanceManager

        let targets = persistanceManager.targets
        if targets.isEmpty {
            persistanceManager.setDefaultTargetsWithLights(lights)
        } else {
            persistanceManager.targets = filterTargets(targets, withAvailableLights: lights)
        }
    }
    
    private func updateSettingsWithScenes(scenes: [LIFXScene]) {
        self.scenes = scenes
        
        var savedScenes = SettingsPersistanceManager.sharedPersistanceManager.scenes
        savedScenes.filter { contains(scenes, $0.scene) }
        SettingsPersistanceManager.sharedPersistanceManager.scenes = savedScenes
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
    
    private func configureDefaultColorsAndIntensities() {
        // We want to have at leat 1 color or 1 intensity.
        let persistanceManager = SettingsPersistanceManager.sharedPersistanceManager
        if persistanceManager.colors.isEmpty && persistanceManager.intensities.isEmpty {
            persistanceManager.setDefaultColors()
            persistanceManager.setDefaultIntensities()
        }
    }
    
}

// LIFX API Handling
extension HomeViewController {
    
    private func fetchLightsAndScenes(completion: (([LIFXLight], [LIFXScene])->())?=nil) {
        let APIWrapper = LIFXAPIWrapper.sharedAPIWrapper()
        APIWrapper.setOAuthToken(SettingsPersistanceManager.sharedPersistanceManager.OAuthToken)

        self.fetchLights { lights in
            self.fetchScenes { scenes in
                SVProgressHUD.dismiss()
                completion?(lights, scenes)
            }
        }
        
    }

    private func fetchLights(completion: (([LIFXLight])->())?=nil) {
        SVProgressHUD.showWithStatus("Fetching lights...")
        LIFXAPIWrapper.sharedAPIWrapper().getAllLightsWithCompletion(
            { result in
                SVProgressHUD.dismiss()
                let lights = result as! [LIFXLight]
                completion?(lights)
            },
            onFailure:
            { error in
                self.displayAPIError(error)
            }
        )
    }
    
    private func fetchScenes(completion: (([LIFXScene])->())?=nil) {
        SVProgressHUD.showWithStatus("Fetching scenes...")
        LIFXAPIWrapper.sharedAPIWrapper().getScenesWithCompletion(
            { result in
                SVProgressHUD.dismiss()
                let scenes = result as! [LIFXScene]
                completion?(scenes)
            },
            onFailure:
            { error in
                self.displayAPIError(error)
            }
        )
        
    }

    private func displayAPIError(error: NSError) {
        SVProgressHUD.dismiss()
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

