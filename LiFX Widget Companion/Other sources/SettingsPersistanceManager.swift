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
    
    var targets: [TargetModelWrapper] {
        get {
            let rawTargets = arrayForKey("targets") as! [[String:String]]?
            return rawTargets?.map { TargetModelWrapper(dictionary: $0)! } ?? []
        }
        set(newTargets) {
            let rawTargets = newTargets.map { $0.toDictionary() }
            saveValue(rawTargets, forKey: "targets")
        }
    }
    
    var colors: [LIFXTargetOperationUpdate] {
        get {
            let rawColors = arrayForKey("colors") as! [[String:AnyObject]]?
            return rawColors?.map { LIFXTargetOperationUpdate(dictionary: $0) } ?? []
        }
        set(newColors) {
            let rawColors = newColors.map { $0.toDictionary() }
            saveValue(rawColors, forKey: "colors")
        }
    }
    
    var intensities: [LIFXTargetOperationUpdate] {
        get {
            let rawIntensities = arrayForKey("intensities") as! [[String:AnyObject]]?
            return rawIntensities?.map { LIFXTargetOperationUpdate(dictionary: $0) } ?? []
        }
        set(newIntensities) {
            let rawIntensities = newIntensities.map { $0.toDictionary() }
            saveValue(rawIntensities, forKey: "intensities")
        }
    }

}

// Default values
extension SettingsPersistanceManager {

    func setDefaultTargetsWithLights(lights: [LIFXLight]) {
        // Default values for lights are all lights, but no groups / locations.
        targets = lights.map { TargetModelWrapper(light: $0) }
    }
    
    func setDefaultColors() {
        let rawColors = [
            [0, 89, 89, 3500], [288, 89, 89, 3500], [236, 64, 98, 3500],
            [177, 82, 100, 3500], [0, 0, 90, 9000],
        ]
        var tmpColors: [LIFXTargetOperationUpdate] = []
        for rawColor in rawColors {
            var color = LIFXColor()
            color.hue = UInt(rawColor[0])
            color.saturation = CGFloat(rawColor[1])
            color.kelvin = UInt(rawColor[2])
            let brightness = CGFloat(rawColor[3])
            tmpColors.append(LIFXTargetOperationUpdate(color: color, brightness: brightness))
        }
        colors = tmpColors
    }
    
    func setDefaultIntensities() {
        let rawIntensities = [ 0.1, 0.5, 1 ]
        var tmpIntensities: [LIFXTargetOperationUpdate] = []
        for rawIntensity in rawIntensities {
            tmpIntensities.append(LIFXTargetOperationUpdate(brightness: CGFloat(rawIntensity)))
        }
        intensities = tmpIntensities
    }
    
}

// Wrapping & unwrapping saved values
extension SettingsPersistanceManager {
    
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
    
    private func arrayForKey(key: String) -> [AnyObject]? {
        return NSUserDefaults(suiteName: "group.LiFXWidgetSharingDefaults")?.arrayForKey(key)
    }
}

// Debug
extension SettingsPersistanceManager {
    
    func logSavedValues() {
        println("targets: [")
        for target in targets {
            println("   id: \(target.identifier), name: \(target.name), selector: \(target.selector),")
        }
        println("]")
        println("colors: [")
        for color in colors {
            println("   \(color),")
        }
        println("]")
        println("intensities: [")
        for intensity in intensities {
            println("   \(intensity),")
        }
        println("]")
    }
    
}
