//
//  RealmUtils.swift
//  AKRealmUtils
//
//  Created by Artem Kalmykov on 10/17/17.
//

import Foundation
import RealmSwift

extension Realm {
    static func encrypt(withKey key: Data) {
    }
    
    static var shared: Realm {
        do {
            return try Realm()
        } catch let error {
            print("Realm initialization error: " + error.localizedDescription)
            exit(0)
        }
    }
    
    static var sharedCharts: Realm {
        do {
            var config = Realm.Configuration()
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("charts.realm")
            
            return try Realm(configuration: config)
        } catch let error {
            print("Realm initialization error: " + error.localizedDescription)
            exit(0)
        }
    }
    
    func finishWrite() {
        do {
            try self.commitWrite()
        } catch let error {
            print("Realm write error: " + error.localizedDescription)
        }
    }
    
    func safeWrite(_ block: (() -> Void)) {
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
    func addToRealm(update: Realm.UpdatePolicy = .error) {
        Realm.shared.add(self, update: update)
    }
    
    @objc func deleteFromRealm() {
        Realm.shared.delete(self)
    }
}
