//
//  AppDelegate.swift
//  LiFXWidget
//
//  Created by Maxime de Chalendar on 23/07/2014.
//  Copyright (c) 2014 Maxime de Chalendar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        themeApplication(application)
        return true
    }

    private func themeApplication(application: UIApplication) {
        let mainColor = UIColor(red: 35/255, green: 178/255, blue: 184/255, alpha: 1)

        SVProgressHUD.setForegroundColor(mainColor)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setFont(UIFont.systemFontOfSize(14))

        let navbarAppearance = UINavigationBar.appearance()
        navbarAppearance.barTintColor = UIColor.blackColor()
        navbarAppearance.tintColor = UIColor.whiteColor()
        navbarAppearance.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor() ]
        
        UIToolbar.appearance().barTintColor = UIColor.blackColor()
        let barButtonItemAppearance =  UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(14)], forState: .Normal)
        barButtonItemAppearance.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(14)], forState: .Disabled)
        
        UISlider.appearance().tintColor = mainColor
        UIButton.appearance().tintColor = mainColor
        TableViewCellSelectedView.appearance().tintColor = mainColor
        
        application.statusBarStyle = .LightContent
    }

}

