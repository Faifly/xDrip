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
    
    static func fetchAllEntries<T: AbstractEntry>(type: T.Type) -> [T] {
        return Array(Realm.shared.objects(T.self).sorted(byKeyPath: "entryDate"))
    }
    
    static func deleteEntry(_ entry: AbstractEntry) {
        let realm = Realm.shared
        realm.safeWrite {
            realm.delete(entry)
        }
    }
}
