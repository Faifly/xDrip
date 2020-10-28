//
//  SettingsAlertSingleTypeModels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum SettingsAlertSingleType {
    // MARK: Models
    
    enum Field {
        case overrideDefault
        case isEnabled
        case name
        case snoozeFromNotification
        case defaultSnooze
        case `repeat`
        case sound
        case vibrate
        case entireDay
        case startTime
        case endTime
        case isUseGlucoseThreshold
        case highTreshold
        case lowTreshold
        case minimumBGChange
    }
    
    // MARK: Use cases
    
    enum Load {
        struct Request {
            let animated: Bool
        }
        
        struct Response {
            let animated: Bool
            let settings: Settings
            let configuration: AlertConfiguration
            let switchValueChangedHandler: (Field, Bool) -> Void
            let textEditingChangedHandler: (String?) -> Void
            let timePickerValueChangedHandler: (Field, TimeInterval) -> Void
            let pickerViewValueChangedHandler: (Field, Double) -> Void
            let selectionHandler: () -> Void
        }
        
        struct ViewModel {
            let animated: Bool
            let title: String
            let tableViewModel: BaseSettings.ViewModel
        }
    }
}
