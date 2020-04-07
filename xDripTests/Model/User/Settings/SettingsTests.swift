//
//  SettingsTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class SettingsTests: AbstractRealmTest {
    func testWarningLevels() {
        let settings = User.current.settings!
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 0)
        
        XCTAssertTrue(settings.warningLevelValue(for: .urgentLow) == GlucoseWarningLevel.urgentLow.defaultValue)
        XCTAssertTrue(settings.warningLevelValue(for: .low) == GlucoseWarningLevel.low.defaultValue)
        XCTAssertTrue(settings.warningLevelValue(for: .high) == GlucoseWarningLevel.high.defaultValue)
        XCTAssertTrue(settings.warningLevelValue(for: .urgentHigh) == GlucoseWarningLevel.urgentHigh.defaultValue)
        
        // When using getters, no objects should be created yet
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 0)
        
        settings.configureWarningLevel(.urgentLow, value: 1.1)
        XCTAssertTrue(abs(settings.warningLevelValue(for: .urgentLow) - 1.1) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 1)
        
        settings.configureWarningLevel(.low, value: 2.2)
        XCTAssertTrue(abs(settings.warningLevelValue(for: .low) - 2.2) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 2)
        
        settings.configureWarningLevel(.high, value: 3.3)
        XCTAssertTrue(abs(settings.warningLevelValue(for: .high) - 3.3) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 3)
        
        settings.configureWarningLevel(.urgentHigh, value: 4.4)
        XCTAssertTrue(abs(settings.warningLevelValue(for: .urgentHigh) - 4.4) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 4)
        
        settings.configureWarningLevel(.urgentHigh, value: 5.5)
        XCTAssertTrue(abs(settings.warningLevelValue(for: .urgentHigh) - 5.5) <= .ulpOfOne)
        XCTAssertTrue(realm.objects(GlucoseWarningLevelSetting.self).count == 4)
    }
    
    func testAbsorptionRateSetting() {
        let settings = User.current.settings!
        XCTAssertTrue(abs(settings.carbsAbsorptionRate - 1200.0) <= .ulpOfOne)
        
        settings.updateCarbsAbsorptionRate(1.1)
        XCTAssertTrue(abs(settings.carbsAbsorptionRate - 1.1) <= .ulpOfOne)
    }
    
    func testInsulinActionTime() {
        let settings = User.current.settings!
        XCTAssertTrue(abs(settings.insulinActionTime - 21600.0) <= .ulpOfOne)
        
        settings.updateInsulinActionTime(1.1)
        XCTAssertTrue(abs(settings.insulinActionTime - 1.1) <= .ulpOfOne)
    }
}
