//
//  SortDescriptor.swift
//  xDrip
//
//  Created by Dmitry on 23.02.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import RealmSwift

extension SortDescriptor {
    static var dateDescending: SortDescriptor {
        return SortDescriptor(keyPath: "date", ascending: false)
    }
}
