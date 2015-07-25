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
    
    var colors: [ColorModelWrapper] {
        get {
            let rawColors = arrayForKey("colors") as! [[String:AnyObject]]?
            return rawColors?.map { ColorModelWrapper(dictionary: $0)! } ?? []
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
    
    var scenes: [SceneModelWrapper] {
        get {
            let rawScenes = arrayForKey("scenes") as! [[String:AnyObject]]?
            return rawScenes?.map { SceneModelWrapper(dictionary: $0) } ?? []
        }
        set(newScenes) {
            let rawScenes = newScenes.map { $0.toDictionary() }
            saveValue(rawScenes, forKey: "scenes")
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
            [0.0, 0.89, 0.89], [0.0, 0.0, 0.9, 1], [0.8, 0.89, 0.89],
            [0.65, 0.64, 0.98], [0.49, 0.82, 1.0],
        ]
        var tmpColors: [ColorModelWrapper] = []
        for rawColor in rawColors {
            let (h, s, b) = (rawColor[0], rawColor[1], rawColor[2])
            if rawColor.count < 4 {
                let color = UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(b), alpha: CGFloat(1))
                tmpColors.append(ColorModelWrapper(color: color))
            }
            else {
                let color = UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(1), alpha: CGFloat(1))
                let white = (Float(rawColor[3]), Float(b))
                tmpColors.append(ColorModelWrapper(color: color, white: white))
            }
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
