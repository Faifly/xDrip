//
//  AbstractEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

protocol AbstractEntryProtocol {
    var amount: Double { get }
    var date: Date? { get }
    var externalID: String? { get }
    var cloudUploadStatus: CloudUploadStatus { get }
}

class AbstractEntry: Object {
    @objc private(set) dynamic var date: Date?
    
    required init() {
        super.init()
    }
    
    init(date: Date) {
        super.init()
        self.date = date
    }
    
    func updateDate(_ date: Date) {
        Realm.shared.safeWrite {
            self.date = date
        }
    }
}
