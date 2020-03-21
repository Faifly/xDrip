//
//  UserTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class UserTests: AbstractRealmTest {
    func testUserSingleton() {
        // Test initial condition
        XCTAssertTrue(realm.objects(User.self).count == 0)
        
        // Test user is correctly created
        var user = User.current
        XCTAssertTrue(realm.objects(User.self).count == 1)
        XCTAssertTrue((user.value(forKey: "id")! as! Int) == 1)
        
        // Test users are not duplicated upon sequential calls
        user = User.current
        XCTAssertTrue(realm.objects(User.self).count == 1)
    }
    
    func testDeviceMode() {
        let user = User.current
        XCTAssertTrue(user.deviceMode == .default)
        XCTAssertFalse(user.isDeviceTypeSet)
        
        user.updateDeviceMode(.follower, isDeviceTypeSet: true)
        XCTAssertTrue(user.deviceMode == .follower)
        XCTAssertTrue(user.isDeviceTypeSet)
        
        user.updateDeviceMode(.main, isDeviceTypeSet: false)
        XCTAssertTrue(user.deviceMode == .main)
        XCTAssertFalse(user.isDeviceTypeSet)
        
        realm.safeWrite {
            user.setValue(-1, forKey: "rawDeviceMode")
        }
        XCTAssertTrue(user.deviceMode == .default)
    }
    
    func testInjectionType() {
        let user = User.current
        XCTAssertTrue(user.injectionType == .default)
        XCTAssertFalse(user.isUserInjectionTypeSet)
        
        user.updateInjectionType(.pen, isInjectionTypeSet: true)
        XCTAssertTrue(user.injectionType == .pen)
        XCTAssertTrue(user.isUserInjectionTypeSet)
        
        user.updateInjectionType(.pump, isInjectionTypeSet: false)
        XCTAssertTrue(user.injectionType == .pump)
        XCTAssertFalse(user.isUserInjectionTypeSet)
        
        realm.safeWrite {
            user.setValue(-1, forKey: "rawInjectionType")
        }
        XCTAssertTrue(user.injectionType == .default)
    }
    
    func testUnit() {
        let user = User.current
        XCTAssertTrue(user.unit == .default)
        XCTAssertFalse(user.isUnitSet)
        
        user.updateUnit(.mgDl, isUnitSet: true)
        XCTAssertTrue(user.unit == .mgDl)
        XCTAssertTrue(user.isUnitSet)
        
        user.updateUnit(.mmolL, isUnitSet: false)
        XCTAssertTrue(user.unit == .mmolL)
        XCTAssertFalse(user.isUnitSet)
        
        realm.safeWrite {
            user.setValue(-1, forKey: "rawUnit")
        }
        XCTAssertTrue(user.unit == .default)
    }
    
    func testWarningLevels() {
        let user = User.current
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 0)
        
        XCTAssertTrue(user.warningLevelValue(for: .urgentLow) == GlucoseWarningLevel.urgentLow.defaultValue)
        XCTAssertTrue(user.warningLevelValue(for: .low) == GlucoseWarningLevel.low.defaultValue)
        XCTAssertTrue(user.warningLevelValue(for: .high) == GlucoseWarningLevel.high.defaultValue)
        XCTAssertTrue(user.warningLevelValue(for: .urgentHigh) == GlucoseWarningLevel.urgentHigh.defaultValue)
        
        // When using getters, no objects should be created yet
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 0)
        
        user.configureWarningLevel(.urgentLow, value: 1.1)
        XCTAssertTrue(abs(user.warningLevelValue(for: .urgentLow) - 1.1) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 1)
        
        user.configureWarningLevel(.low, value: 2.2)
        XCTAssertTrue(abs(user.warningLevelValue(for: .low) - 2.2) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 2)
        
        user.configureWarningLevel(.high, value: 3.3)
        XCTAssertTrue(abs(user.warningLevelValue(for: .high) - 3.3) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 3)
        
        user.configureWarningLevel(.urgentHigh, value: 4.4)
        XCTAssertTrue(abs(user.warningLevelValue(for: .urgentHigh) - 4.4) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 4)
        
        user.configureWarningLevel(.urgentHigh, value: 5.5)
        XCTAssertTrue(abs(user.warningLevelValue(for: .urgentHigh) - 5.5) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 4)
    }
    
    func testGlucoseData() {
        let user = User.current
        XCTAssertTrue(user.glucoseData.count == 0)
        
        let now = Date().timeIntervalSince1970
        user.addGlucoseDataEntry(1.1)
        
        XCTAssertTrue(user.glucoseData.count == 1)
        XCTAssertTrue(abs(user.glucoseData[0].value - 1.1) <= .ulpOfOne)
        XCTAssertTrue(abs(user.glucoseData[0].date!.timeIntervalSince1970.rounded() - now.rounded()) <= .ulpOfOne)
        
        let past = Date(timeIntervalSince1970: 6.0)
        user.addGlucoseDataEntry(2.2, date: past)
        
        XCTAssertTrue(user.glucoseData.count == 2)
        XCTAssertTrue(abs(user.glucoseData[1].value - 2.2) <= .ulpOfOne)
        XCTAssertTrue(abs(user.glucoseData[1].date!.timeIntervalSince1970 - 6.0) <= .ulpOfOne)
    }
    
    func testInsulinChartSetting() {
        let user = User.current
        XCTAssertTrue(user.isInsulinChartEnabled)
        
        user.updateInsulinChartEnabled(false)
        XCTAssertFalse(user.isInsulinChartEnabled)
        
        user.updateInsulinChartEnabled(true)
        XCTAssertTrue(user.isInsulinChartEnabled)
    }
    
    func testCarbsChartSetting() {
        let user = User.current
        XCTAssertTrue(user.isCarbohydratesChartEnabled)
        
        user.updateCarbohydratesChartEnabled(false)
        XCTAssertFalse(user.isCarbohydratesChartEnabled)
        
        user.updateCarbohydratesChartEnabled(true)
        XCTAssertTrue(user.isCarbohydratesChartEnabled)
    }
    
    func testAbsorptionRateSetting() {
        let user = User.current
        XCTAssertTrue(abs(user.carbsAbsorptionRate - 1200.0) <= .ulpOfOne)
        
        user.updateCarbsAbsorptionRate(1.1)
        XCTAssertTrue(abs(user.carbsAbsorptionRate - 1.1) <= .ulpOfOne)
    }
    
    func testInsulinActionTime() {
        let user = User.current
        XCTAssertTrue(abs(user.insulinActionTime - 21600.0) <= .ulpOfOne)
        
        user.updateInsulinActionTime(1.1)
        XCTAssertTrue(abs(user.insulinActionTime - 1.1) <= .ulpOfOne)
    }
}
