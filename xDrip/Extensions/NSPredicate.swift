//
//  NSPredicate.swift
//  xDrip
//
//  Created by Dmitry on 22.02.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

extension NSPredicate {
    static var rawValue: NSPredicate {
        return NSPredicate(format: "rawValue > %@",
                           NSNumber(value: Double(Float32.ulpOfOne)))
    }
    
    static var calculatedValue: NSPredicate {
        return NSPredicate(format: "calculatedValue > %@",
                           NSNumber(value: Double(Float32.ulpOfOne)))
    }
    
    static var filteredCalculatedValue: NSPredicate {
        return NSPredicate(format: "filteredCalculatedValue > %@",
                           NSNumber(value: Double.ulpOfOne))
    }
    
    static func deviceMode(mode: UserDeviceMode) -> NSPredicate {
        let modeString = mode == .main ? UserDeviceMode.main.rawValue : UserDeviceMode.follower.rawValue
        return NSPredicate(format: "rawDeviceMode == \(modeString)")
    }
    
    static func laterThan(date: Date) -> NSPredicate {
        return NSPredicate(format: "date > %@", argumentArray: [date])
    }
    
    static func earlierThan(date: Date) -> NSPredicate {
        return NSPredicate(format: "date < %@", argumentArray: [date])
    }
    
    static func laterThanOrEqual(date: Date) -> NSPredicate {
        return NSPredicate(format: "date >= %@", argumentArray: [date])
    }
    
    static func earlierThanOrEqual(date: Date) -> NSPredicate {
        return NSPredicate(format: "date <= %@", argumentArray: [date])
    }
    
    static var valid: NSPredicate {
        return NSPredicate(format: "rawCalibrationState != %@",
                           argumentArray: [String(DexcomG6CalibrationState.warmingUp.rawValue)])
    }
}
