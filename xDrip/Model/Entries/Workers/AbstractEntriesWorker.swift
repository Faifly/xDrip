//
//  AbstractEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

// swiftlint:disable convenience_type

class AbstractEntriesWorker {
    @discardableResult static func add<T: AbstractEntry>(entry: T) -> T {
        let realm = Realm.shared
        realm.safeWrite {
            realm.add(entry)
        }
        return entry
    }
    
    static func fetchAllEntries<T: AbstractEntry>(type: T.Type) -> Results<T> {
        return Realm.shared.objects(T.self).sorted(byKeyPath: "date")
    }
    
    static func deleteAllEntries<T: AbstractEntry>(type: T.Type, mode: UserDeviceMode, filter: NSPredicate? = nil) {
        var subpredicates: [NSPredicate] = [.deviceMode(mode: mode)]
        if let filter = filter {
            subpredicates.append(filter)
        }
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)
        let objects = Realm.shared.objects(T.self).filter(andPredicate)
        let realm = Realm.shared
        realm.safeWrite {
            realm.delete(objects)
        }
    }
    
    static func deleteEntry(_ entry: AbstractEntry) {
        let realm = Realm.shared
        realm.safeWrite {
            realm.delete(entry)
        }
    }
}
