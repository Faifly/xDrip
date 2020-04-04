//
//  DexcomG6OutgoingMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol DexcomG6OutgoingMessage {
    var data: Data { get }
    var characteristic: DexcomG6CharacteristicType { get }
}
