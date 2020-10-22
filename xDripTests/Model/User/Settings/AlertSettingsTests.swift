//
//  AlertSettingsTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class AlertSettingsTests: AbstractRealmTest {
    func testGetSound() {
        guard let settings = User.current.settings.alert else {
            XCTFail("Cannot obtain alert settings")
            return
        }
        
        let defaultConfig = settings.defaultConfiguration
        defaultConfig?.updateSoundID(3)
        
        XCTAssert(settings.getSound(for: .fastRise) == .bloom)
        
        let config = settings.customConfiguration(for: .fastRise)
        config.updateIsOverride(true)
        config.updateSoundID(0)
        
        XCTAssert(settings.getSound(for: .fastRise) == .alarm)
    }
}
