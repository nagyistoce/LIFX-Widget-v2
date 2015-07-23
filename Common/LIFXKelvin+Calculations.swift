//
//  LIFXKelvin+Calculations.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 21/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import Foundation

func rawKelvinToRatio(rawKelvin: UInt) -> Float {
    return (Float(rawKelvin) - 2500) / (9000 - 2500)
}

func ratioToRawKelvin(ratio: Float) -> UInt {
    return UInt(ratio * (9000 - 2500)) + 2500
}