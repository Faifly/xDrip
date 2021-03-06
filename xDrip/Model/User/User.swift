//
//  User.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

// swiftlint:disable implicitly_unwrapped_optional

final class User: Object {
    // MARK: Access
    
    private static let singleUserID: Int = 1
    @objc private dynamic var identifier: Int = User.singleUserID
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    required init() {
        super.init()
        settings = Settings()
    }
    
    static var current: User {
        let realm = Realm.shared
        if let user = realm.object(ofType: User.self, forPrimaryKey: User.singleUserID) {
            return user
        }
        
        let user = User()
        realm.safeWrite {
            realm.add(user)
        }
        return user
    }
    
    static var currentAsync: User? {
        let realm = try? Realm()
        return realm?.object(ofType: User.self, forPrimaryKey: User.singleUserID)
    }
    
    // MARK: Settings
    @objc private(set) dynamic var settings: Settings!
    
    // MARK: Initial setup
    
    @objc private(set) dynamic var isWarningAgreed = false
    @objc private(set) dynamic var isInitialSetupDone = false
    
    func setIsWarningAgreed(_ agreed: Bool) {
        Realm.shared.safeWrite {
            self.isWarningAgreed = agreed
        }
    }
    
    func setIsInitialSetupDone(_ done: Bool) {
        Realm.shared.safeWrite {
            self.isInitialSetupDone = done
        }
    }
}
