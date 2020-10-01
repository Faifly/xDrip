//
//  CDeviceStatus.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct CDeviceStatus: Decodable {
    let pump: CPumpInfo?
}

struct CPumpInfo: Decodable {
    let suspended: Bool?
    let pumpID: String?
    let bolusing: Bool?
    let clock: String?
    let manufacturer: String?
    let model: String?
    let secondsFromGMT: Int?
}
