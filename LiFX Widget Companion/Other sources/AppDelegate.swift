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
        application.statusBarStyle = .LightContent

        let mainColor = UIColor(red: 35/255, green: 178/255, blue: 184/255, alpha: 1)
        UIView.appearance().tintColor = mainColor

        SVProgressHUD.setForegroundColor(mainColor)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setFont(UIFont.systemFontOfSize(14))
    }

}

