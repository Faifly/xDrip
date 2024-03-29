//
//  NightscoutCloudConfigurationModels.swift
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

enum NightscoutCloudConfiguration {
    // MARK: Models
    
    enum Field {
        case enabled
        case useCellularData
        case sendDisplayGlucose
        case baseURL
        case apiSecret
        case testConnection
        case downloadData
        case extraOptions
    }
    
    // MARK: Use cases
    
    enum UpdateData {
        struct Request {
        }
        
        struct Response {
            let settings: NightscoutSyncSettings
            let switchValueChangedHandler: (Field, Bool) -> Void
            let textEditingChangedHandler: (Field, String?) -> Void
            let singleSelectionHandler: () -> Void
            let testConnectionHandler: () -> Void
        }
        
        struct ViewModel {
            let tableViewModel: BaseSettings.ViewModel
        }
    }
}
