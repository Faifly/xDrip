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
        case .pairingRequest: return "notification_pairing_request_title".localized
        }
    }
    
    var body: String {
        switch self {
        case .pairingRequest: return "notification_pairing_request_body".localized
        }
    }
    
    var identifier: String {
        switch self {
        case .pairingRequest: return "pairingRequest"
        }
    }
}
