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
}
