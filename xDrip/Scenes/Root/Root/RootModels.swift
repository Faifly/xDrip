//
//  RootModels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum Root {
    // MARK: Models
    
    enum TabButton {
        case calibration
        case chart
        case plus
        case history
        case settings
    }
    
    enum EntryType {
        case injection
        case food
        case training
        case calibration
        case bolus
        case carbs
        case basal
    }
    
    // MARK: Use cases
    
    enum Load {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum InitialSetup {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum TabSelection {
        struct Request {
            let button: TabButton
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum ShowAddEntryOptionsList {
        struct Request {
        }
        
        struct Response {
            let types: [EntryType]
        }
        
        struct ViewModel {
            let titles: [String]
        }
    }
    
    enum ShowAddEntry {
        struct Request {
            let index: Int
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
}

extension Root.EntryType {
    var shortLabel: String {
        switch self {
        case .bolus:
            return "entries_list_scene_carbs_bolus_unit".localized
        case .calibration:
            return ""
        case .carbs:
            return "entries_list_scene_carbs_amount_unit_grams".localized
        case .food:
            return ""
        case .injection:
            return ""
        case .training:
            return ""
        }
    }
}
