//
//  SettingsRootModels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum SettingsRoot {
    // MARK: Models
    
    enum Field {
        case chartSettings
        case alert
        case cloudUpload
        case modeSettings
        case sensor
        case transmitter
        case rangeSelection
        case userType
        case units
        case carbsDurationTime
        case insulinDurationTime
        case nightscoutService
        case debugLogs
    }
    
    // MARK: Use cases
    
    enum Load {
        struct Request {
        }
        
        struct Response {
            let deviceMode: UserDeviceMode
            let injectionType: UserInjectionType
            let selectionHandler: (Field) -> Void
            let timePickerValueChangedHandler: (Field, TimeInterval) -> Void
        }
        
        struct ViewModel {
            let tableViewModel: BaseSettings.ViewModel
        }
    }
    
    enum Cancel {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
}
