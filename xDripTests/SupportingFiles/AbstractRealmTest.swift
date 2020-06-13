//
//  AbstractRealmTest.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
import RealmSwift
@testable import xDrip

class AbstractRealmTest: XCTestCase {
    let realm = Realm.shared
    
    override func setUp() {
        super.setUp()
        Realm.shared.safeWrite {
            Realm.shared.deleteAll()
        }
    }
}

extension GlucoseReading {
    func generateID() {
        setValue(UUID().uuidString, forKey: "externalID") 
    }
}
