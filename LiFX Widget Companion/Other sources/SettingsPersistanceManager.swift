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
    
    var intensities: [IntensityModelWrapper] {
        get {
            let rawIntensities = arrayForKey("intensities") as! [[String:AnyObject]]?
            return rawIntensities?.map { IntensityModelWrapper(dictionary: $0)! } ?? []
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
            [0, 0.89, 0.89], [0, 0.0, 0.9, 9000], [288, 0.89, 0.89],
            [236, 0.64, 0.98], [177, 0.82, 1.0],
        ]
        var tmpColors: [LIFXTargetOperationUpdate] = []
        for rawColor in rawColors {
            var color = LIFXColor()
            if rawColor.count < 4 {
                color.hue = UInt(rawColor[0])
                color.saturation = CGFloat(rawColor[1])
            }
            else {
                color.kelvin = UInt(rawColor[3])
            }
            let brightness = CGFloat(rawColor[2])
            tmpColors.append(LIFXTargetOperationUpdate(color: color, brightness: brightness))
        }
        colors = tmpColors
    }
    
    func setDefaultIntensities() {
        let rawIntensities = [ ["Low", 0.1], ["Medium", 0.5], ["High", 1] ]
        var tmpIntensities: [IntensityModelWrapper] = []
        for rawIntensity in rawIntensities {
            let name = rawIntensity[0] as! String
            let brightness = rawIntensity[1] as! Float
            tmpIntensities.append(IntensityModelWrapper(name: name, brightness: brightness))
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
