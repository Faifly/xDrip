//
//  AlertEventType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum AlertEventType: Int, CaseIterable {
    case `default`
    case fastRise
    case urgentHigh
    case high
    case fastDrop
    case low
    case urgentLow
    case missedReadings
    case phoneMuted
}
