//
//  NightscoutError.swift
//  xDrip
//
//  Created by Artem Kalmykov on 12.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum NightscoutError: Error {
    case invalidURL
    case invalidAPISecret
    case cantConnect
    case noAPISecret
}
