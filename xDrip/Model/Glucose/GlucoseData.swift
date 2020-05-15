//
//  GlucoseData.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift
import AKUtils

final class GlucoseReading: Object {
    @objc private(set) dynamic var value: Double = 0.0
    #warning("Check if saved")
    @objc private(set) dynamic var rawValue: Double = 0.0
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var calculatedValue: Double = 0.0
    @objc private(set) dynamic var filteredCalculatedValue: Double = 0.0
    @objc private(set) dynamic var isCalibrated: Bool = false
    @objc private(set) dynamic var a: Double = 0.0
    @objc private(set) dynamic var b: Double = 0.0
    @objc private(set) dynamic var c: Double = 0.0
    @objc private(set) dynamic var ra: Double = 0.0
    @objc private(set) dynamic var rb: Double = 0.0
    @objc private(set) dynamic var rc: Double = 0.0
    @objc private(set) dynamic var ageAdjustedRawValue: Double = 0.0
    @objc private(set) dynamic var calibration: Calibration?
    @objc private(set) dynamic var hideSlope: Bool = false
    
    init(value: Double, date: Date = Date()) {
        super.init()
        self.value = value
        self.date = date
    }
    
    required init() {
        super.init()
    }
    
    static var all: [GlucoseReading] {
        return Array(Realm.shared.objects(GlucoseReading.self).sorted(byKeyPath: "date"))
    }
    
    static func lastReadings(_ amount: Int) -> [GlucoseReading] {
        let allReadings = all
        if allReadings.count > amount {
            return Array(allReadings[(allReadings.count - amount - 1)...(allReadings.count - 1)]).reversed()
        }
        
        return Array(allReadings).reversed()
    }
    
    static func lastUncalculated(_ amount: Int) -> [GlucoseReading] {
        let allReadings = all.filter { abs($0.rawValue) > .ulpOfOne }
        if allReadings.count > amount {
            return Array(allReadings[(allReadings.count - amount - 1)...(allReadings.count - 1)]).reversed()
        }
        
        return Array(allReadings).reversed()
    }
    
    static func reading(for date: Date) -> GlucoseReading? {
        let allowedOffset = TimeInterval.secondsPerMinute * 15.0
        let minOffset = date - allowedOffset
        let maxOffset = date + allowedOffset
        let matching = all.filter { $0.date >? minOffset && $0.date <? maxOffset }
        let offsets = matching.map { abs(($0.date?.timeIntervalSince1970 ?? .greatestFiniteMagnitude) - date.timeIntervalSince1970) }
        
        var min = TimeInterval.greatestFiniteMagnitude
        var minIndex: Int?
        for (i, offset) in offsets.enumerated() {
            if offset < min {
                min = offset
                minIndex = i
            }
        }
        
        if let minIndex = minIndex {
            return matching[minIndex]
        }
        
        return nil
    }
    
    func updateCalculatedValue(_ value: Double) {
        Realm.shared.safeWrite {
            self.calculatedValue = value
        }
    }
    
    func updateFilteredCalculatedValue(_ value: Double) {
        Realm.shared.safeWrite {
            self.filteredCalculatedValue = value
        }
    }
    
    func updateIsCalibrated(_ isCalibrated: Bool) {
        Realm.shared.safeWrite {
            self.isCalibrated = isCalibrated
        }
    }
    
    func findNewCurve() {
        let curve = findCurve(valueKey: "calculatedValue")
        
        Realm.shared.safeWrite {
            self.a = curve.a
            self.b = curve.b
            self.c = curve.c
        }
    }
    
    func findNewRawCurve() {
        let curve = findCurve(valueKey: "ageAdjustedRawValue")
        
        Realm.shared.safeWrite {
            self.ra = curve.a
            self.rb = curve.b
            self.rc = curve.c
        }
    }
    
    func updateCalibration(_ calibration: Calibration?) {
        Realm.shared.safeWrite {
            self.calibration = calibration
        }
    }
    
    private func findCurve(valueKey: String) -> (a: Double, b: Double, c: Double) {
        let last3 = GlucoseReading.lastReadings(3)
        
        let a: Double
        let b: Double
        let c: Double
        
        if last3.count == 3 {
            let y3 = last3[0].value(forKey: valueKey) as? Double ?? 1.0
            let x3 = last3[0].date?.timeIntervalSince1970 ?? 1.0
            let y2 = last3[1].value(forKey: valueKey) as? Double ?? 1.0
            let x2 = last3[1].date?.timeIntervalSince1970 ?? 1.0
            let y1 = last3[2].value(forKey: valueKey) as? Double ?? 1.0
            let x1 = last3[2].date?.timeIntervalSince1970 ?? 1.0
            
            a = y1 / ((x1 - x2) * (x1 - x3)) + y2 / ((x2 - x1) * (x2 - x3)) + y3 / ((x3 - x1) * (x3 - x2))
            b = (-y1 * (x2 + x3) / ((x1 - x2) * (x1 - x3)) - y2 * (x1 + x3) / ((x2 - x1) * (x2 - x3)) - y3 * (x1 + x2) / ((x3 - x1) * (x3 - x2)))
            c = (y1 * x2 * x3 / ((x1 - x2) * (x1 - x3)) + y2 * x1 * x3 / ((x2 - x1) * (x2 - x3)) + y3 * x1 * x2 / ((x3 - x1) * (x3 - x2)))
        } else if last3.count == 2 {
            let y2 = last3[0].value(forKey: valueKey) as? Double ?? 1.0
            let x2 = last3[0].date?.timeIntervalSince1970 ?? 1.0
            let y1 = last3[1].value(forKey: valueKey) as? Double ?? 1.0
            let x1 = last3[1].date?.timeIntervalSince1970 ?? 1.0
            let lastB = last3[0].b
            
            if abs(y1 - y2) <= .ulpOfOne {
                b = 0
            } else {
                b = (y2 - y1) / (x2 - x1)
            }
            a = 0
            c = -1 * ((lastB * x1) - y1)
        } else {
            a = 0
            b = 0
            c = calculatedValue
        }
        
        return (a, b, c)
    }
    
    func updateCalculatedValueToWithinMinMax() {
        Realm.shared.safeWrite {
            if calculatedValue < 10.0 {
                calculatedValue = -1.0
                hideSlope = true
            } else {
                calculatedValue = min(400.0, max(39.0, calculatedValue))
            }
        }
    }
}
