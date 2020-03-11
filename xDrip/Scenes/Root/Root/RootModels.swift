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
        }
        
        struct ViewModel {
        }
    }
    
    enum ShowAddEntry {
        struct Request {
            let type: EntryType
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
}
