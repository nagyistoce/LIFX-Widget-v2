//
//  SettingsPersistanceManager.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 29/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class SettingsPersistanceManager: NSObject {
    static let sharedPersistanceManager = SettingsPersistanceManager()

    var OAuthToken: String? {
        get {
            return stringForKey("OAuthToken")
        }
        set(newToken) {
            saveValue(newToken, forKey: "OAuthToken")
            LIFXAPIWrapper.sharedAPIWrapper().setOAuthToken(newToken)
        }
    }
    var hasOAuthToken: Bool {
        return OAuthToken != nil
    }

    private func saveValue(value: AnyObject?, forKey key: String) {
        if let unwrappedValue: AnyObject = value {
            NSUserDefaults(suiteName: "group.LiFXWidgetSharingDefaults")?.setObject(unwrappedValue, forKey: key)
        } else {
            NSUserDefaults(suiteName: "group.LiFXWidgetSharingDefaults")?.removeObjectForKey(key)
        }
    }

    private func stringForKey(key: String) -> String? {
        return NSUserDefaults(suiteName: "group.LiFXWidgetSharingDefaults")?.stringForKey(key)
    }
}
