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
}
