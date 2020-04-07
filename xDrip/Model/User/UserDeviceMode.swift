//
//  UserDeviceMode.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum UserDeviceMode: Int {
    case main
    case follower
    
    static var `default`: UserDeviceMode {
        return .main
    }
}
