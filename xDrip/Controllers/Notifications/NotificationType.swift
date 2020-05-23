//
//  NotificationType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum NotificationType {
    case pairingRequest
    
    var title: String {
        switch self {
        case .pairingRequest: return "Pairing request".localized
        }
    }
    
    var body: String {
        switch self {
        case .pairingRequest: return "Please open your phone and confirm pairing request from your transmitter".localized
        }
    }
    
    var identifier: String {
        switch self {
        case .pairingRequest: return "pairingRequest"
        }
    }
}
