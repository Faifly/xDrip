//
//  Settings+Notifications_Tests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class Settings_Notifications_Tests: XCTestCase {
    var notificationHandlerCalled = false
    
    override func setUp() {
        super.setUp()
        
        _ = NotificationCenter.default.subscribe(forSettingsChange: [.unit]) {
            self.notificationHandlerCalled = true
        }
    }
    
    func testNotifications() {
        // When
        NotificationCenter.default.postSettingsChangeNotification(setting: .unit)
        // Then
        XCTAssertTrue(notificationHandlerCalled)
    }
}
