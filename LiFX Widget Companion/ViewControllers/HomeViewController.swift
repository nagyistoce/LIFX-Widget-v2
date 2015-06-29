//
//  HomeViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 28/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        presentTutorialViewControllerIfNeeded()
    }

    func presentTutorialViewControllerIfNeeded() {
        if !SettingsPersistanceManager.sharedPersistanceManager.hasOAuthToken {
            performSegueWithIdentifier("TutorialViewController", sender: nil)
        }
    }

}

