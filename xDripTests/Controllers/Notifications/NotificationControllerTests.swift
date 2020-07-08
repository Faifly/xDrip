//
//  NotificationControllerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 02.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class NotificationContorllerTests: AbstractRealmTest {
    let sut = NotificationController.shared
    
    func testSendNotification() {
        let settings = User.current.settings.alert
        guard
            let defaultConfig = settings?.defaultConfiguration,
            let config = settings?.customConfiguration(for: .fastRise)
        else {
            XCTFail("Cannot obtain alert configurations")
            return
        }
        config.updateIsEnabled(false)
        config.updateSnoozedUntilDate(Date(timeIntervalSince1970: 1.0))
        settings?.updateNotificationEnabled(false)
        sut.sendNotification(ofType: .fastRise)
        
        settings?.updateNotificationEnabled(true)
        sut.sendNotification(ofType: .fastRise)
        
        defaultConfig.updateSnoozeFromNotification(true)
        sut.sendNotification(ofType: .fastRise)
        
        config.updateIsEntireDay(false)
        config.updateStartTime(86400.0)
        config.updateEndTime(75600.0) // 60 * 60 * 21
        sut.sendNotification(ofType: .fastRise)
        
        config.updateStartTime(0.0)
        config.updateName("FaSt RiSe")
        config.updateIsVibrating(true)
        config.updateIsEnabled(true)
        sut.sendNotification(ofType: .fastRise)
        
        config.updateSnoozeFromNotification(true)
        sut.sendNotification(ofType: .fastRise)
    }
    
    func testScheduleSnoozeFromNotificatio() {
        let settings = User.current.settings.alert
        guard
            let defaultConfig = settings?.defaultConfiguration,
            let config = settings?.customConfiguration(for: .fastRise)
        else {
            XCTFail("Cannot obtain alert configurations")
            return
        }
        config.updateIsEnabled(false)
        
        var date = Date()
        defaultConfig.updateDefaultSnooze(360.0)
        sut.scheduleSnoozeForNotification(ofType: .fastRise)
        
        XCTAssertTrue(config.snoozedUntilDate.timeIntervalSince(date) ~~ 360.0)
        
        date = Date()
        config.updateIsEnabled(true)
        config.updateDefaultSnooze(180.0)
        sut.scheduleSnoozeForNotification(ofType: .fastRise)
        
        XCTAssertTrue(config.snoozedUntilDate.timeIntervalSince(date) ~~ 180.0)
        
        sut.sendNotification(ofType: .fastRise)
    }
}
