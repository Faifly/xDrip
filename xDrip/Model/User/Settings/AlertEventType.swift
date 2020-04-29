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
    
    var title: String {
        switch self {
        case .default: return "settings_alert_event_type_title_default".localized
        case .fastRise: return "settings_alert_event_type_title_fast_rise".localized
        case .urgentHigh: return "settings_alert_event_type_title_urgent_high".localized
        case .high: return "settings_alert_event_type_title_high".localized
        case .fastDrop: return "settings_alert_event_type_title_fast_drop".localized
        case .low: return "settings_alert_event_type_title_low".localized
        case .urgentLow: return "settings_alert_event_type_title_urgent_low".localized
        case .missedReadings: return "settings_alert_event_type_title_missed_readings".localized
        case .phoneMuted: return "settings_alert_event_type_title_phone_muted".localized
        }
    }
}
