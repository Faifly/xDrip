//
//  RealmUtils.swift
//  AKRealmUtils
//
//  Created by Artem Kalmykov on 10/17/17.
//

import Foundation
import RealmSwift

extension Realm {
    private static var sharedRealm: Realm = {
        do {
            return try Realm()
        } catch let error {
            print("Realm initialization error: " + error.localizedDescription)
            exit(0)
        }
    }()
    
    public static func encrypt(withKey key: Data) {
    }
    
    public static var shared: Realm {
        return self.sharedRealm
    }
    
    public func finishWrite() {
        do {
            try self.commitWrite()
        } catch let error {
            print("Realm write error: " + error.localizedDescription)
        }
    }
    
    public func safeWrite(_ block: (() -> Void)) {
        if self.isInWriteTransaction {
            block()
        } else {
            do {
                try self.write(block)
            } catch let error {
                print("Realm write error: " + error.localizedDescription)
            }
        }
    }
}

extension Object {
    public func addToRealm(update: Realm.UpdatePolicy = .error) {
        Realm.shared.add(self, update: update)
    }
    
    @objc open func deleteFromRealm() {
        Realm.shared.delete(self)
    }
}
