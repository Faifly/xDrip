//
//  CGMBluetoothService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol CGMBluetoothService {
    init(delegate: CGMBluetoothServiceDelegate)
    
    func connect()
    func disconnect()
    func sendCalibration(glucose: Int, date: Date)
}
