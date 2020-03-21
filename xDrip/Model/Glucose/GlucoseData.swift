//
//  GlucoseData.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class GlucoseData: Object {
    @objc private(set) dynamic var value: Double = 0.0
    @objc private(set) dynamic var date: Date?
    
    init(value: Double, date: Date = Date()) {
        super.init()
        self.value = value
        self.date = date
    }
    
    required init() {
        super.init()
    }
}
