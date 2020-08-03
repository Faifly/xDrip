//
//  GlucoseNotificationWorkerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 02.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class GlucoseNotificationsWorkerTests: AbstractRealmTest {
    var sut: GlucoseNotificationWorker?
    
    func testGlucoseChangingFast() {
        sut = GlucoseNotificationWorker()
        
        CGMDevice.current.sensorStartDate = Date().addingTimeInterval(-86400.0)
        CGMDevice.current.updateSensorIsStarted(true)
        
        GlucoseReading.create(filtered: 120.0, unfiltered: 120.0, rssi: 0.0, date: Date().addingTimeInterval(-600))
        GlucoseReading.create(filtered: 135.0, unfiltered: 135.0, rssi: 0.0, date: Date().addingTimeInterval(-300))
        
        try? Calibration.createInitialCalibration(
            glucoseLevel1: 80.0,
            glucoseLevel2: 120.0,
            date1: Date().addingTimeInterval(-7200.0),
            date2: Date().addingTimeInterval(-3600.0)
        )
        
        CGMController.shared.serviceDidReceiveGlucoseReading(raw: 150.0, filtered: 150.0, rssi: 0.0)
        CGMController.shared.serviceDidReceiveGlucoseReading(raw: 170.0, filtered: 170.0, rssi: 0.0)
        CGMController.shared.serviceDidReceiveGlucoseReading(raw: 150.0, filtered: 150.0, rssi: 0.0)
        CGMController.shared.serviceDidReceiveGlucoseReading(raw: 130.0, filtered: 130.0, rssi: 0.0)
    }
    
    func testSetupRepeatAlerts() {
        let alertSettings = User.current.settings.alert
        let fastRise = alertSettings?.customConfiguration(for: .fastRise)
        fastRise?.updateRepeat(true)
        fastRise?.updateIsEnabled(true)
        
        let defaultConfig = alertSettings?.defaultConfiguration
        defaultConfig?.updateRepeat(true)
        
        sut = GlucoseNotificationWorker()
    }
}
