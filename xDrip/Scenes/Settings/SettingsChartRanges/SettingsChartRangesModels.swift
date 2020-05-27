//
//  SettingsChartRangesModels.swift
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

enum SettingsChartRanges {
    // MARK: Models
    enum Field {
        case notHigherLess
        case highLow
        case urgent
    }
    
    // MARK: Use cases
    
    enum UpdateData {
        struct Request {
        }
        
        struct Response {
            let settings: Settings
            let pickerValueChanged: (Field, [Double]) -> Void
        }
        
        struct ViewModel {
            let tableViewModel: BaseSettings.ViewModel
        }
    }
}
