//
//  UserInjectionType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum UserInjectionType: Int, CaseIterable {
    case pen
    case pump
    
    static var `default`: UserInjectionType {
        return .pen
    }
}
