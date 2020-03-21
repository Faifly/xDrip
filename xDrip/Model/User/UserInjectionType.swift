//
//  UserInjectionType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension User {
    enum InjectionType: Int {
        case pen
        case pump
        
        static var `default`: InjectionType {
            return .pen
        }
    }
}
