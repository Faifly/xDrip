//
//  LogController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import os

struct LogController {
    static func log(message: StaticString, type: OSLogType, _ args: CVarArg...) {
        switch args.count {
        case 0: os_log(message, log: .default, type: type)
        case 1: os_log(message, log: .default, type: type, args[0])
        case 2: os_log(message, log: .default, type: type, args[0], args[1])
        case 3: os_log(message, log: .default, type: type, args[0], args[1], args[2])
        case 4: os_log(message, log: .default, type: type, args[0], args[1], args[2], args[3])
        case 5: os_log(message, log: .default, type: type, args[0], args[1], args[2], args[3], args[4])
        case 6: os_log(message, log: .default, type: type, args[0], args[1], args[2], args[3], args[4], args[5])
        default: os_log(message, log: .default, type: type, args)
        }
        DebugController.shared.log(message: message, args: args)
    }
    
    static func log(message: StaticString, type: OSLogType, error: Error?) {
        log(message: message, type: type, error?.localizedDescription ?? "no error")
    }
}
