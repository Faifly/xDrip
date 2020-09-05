//
//  EditTrainingModels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum EditTraining {
    // MARK: Models
    
    enum Field {
        case duration
        case intensity
        case dateTime
    }
    
    enum Mode {
        case create
        case edit(_ entry: TrainingEntry)
    }
    
    // MARK: Use cases
    
    enum Load {
        struct Request {
        }
        
        struct Response {
            let trainingEntry: TrainingEntry?
            let dateChangedHandler: (Date) -> Void
            let timeIntervalChangedHandler: (TimeInterval) -> Void
            let trainingIntensityChangedHandler: (TrainingIntensity) -> Void
        }
        
        struct ViewModel {
            let tableViewModel: BaseSettings.ViewModel
        }
    }
    
    enum Done {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
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