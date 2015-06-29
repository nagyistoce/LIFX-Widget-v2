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

    func presentTutorialViewControllerIfNeeded() -> Bool {
        if !SettingsPersistanceManager.sharedPersistanceManager.hasOAuthToken {
            performSegueWithIdentifier("TutorialViewController", sender: nil)
            return true
        }
        return false
    }

    private func configureTutorialViewController(tutorialViewController: TutorialViewController) {
        tutorialViewController.onValidation = { lights in
            self.lights = lights
        }
    }
}

// LIFX API Handling
extension HomeViewController {

    private func fetchLights() {
        let APIWrapper = LIFXAPIWrapper.sharedAPIWrapper()
        APIWrapper.setOAuthToken(SettingsPersistanceManager.sharedPersistanceManager.OAuthToken)

        APIWrapper.getAllLightsWithCompletion(
            { lights in
                self.lights = lights as! [LIFXLight]
            },
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

