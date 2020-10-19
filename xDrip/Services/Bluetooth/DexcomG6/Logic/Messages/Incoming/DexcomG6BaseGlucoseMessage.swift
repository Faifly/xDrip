//
//  DexcomG6BaseGlucoseMessage.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.10.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol DexcomG6BaseGlucoseMessageProtocol {
    var status: UInt8 { get }
    var filtered: Double { get }
    var unfiltered: Double { get }
}
