//
//  HomeModels.swift
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

enum Home {
    // MARK: Models
    
    struct WarmUpState {
        let isWarmingUp: Bool
        let minutesLeft: Int?
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
    
    enum GlucoseDataUpdate {
        struct Request {
        }
        
        struct Response {
            let glucoseData: [GlucoseReading]
        }
        
        struct ViewModel {
            let glucoseValues: [GlucoseChartGlucoseEntry]
            let unit: String
        }
    }
    
    enum ShowEntriesList {
        struct Request {
            let entriesType: Root.EntryType
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum ChangeGlucoseChartTimeFrame {
        struct Request {
            let hours: Int
        }
        
        struct Response {
            let timeInterval: TimeInterval
        }
        
        struct ViewModel {
            let timeInterval: TimeInterval
        }
    }
    
    enum GlucoseCurrentInfo {
        struct Request {
        }
        
        struct Response {
            let lastGlucoseReading: GlucoseReading?
        }
        
        struct ViewModel {
            let glucoseIntValue: String
            let glucoseDecimalValue: String
            let slopeValue: String
            let lastScanDate: String
            let difValue: String
            let severityColor: UIColor?
        }
    }
    
    enum WarmUp {
        struct Response {
            let state: Home.WarmUpState
        }
        
        struct ViewModel {
            let shouldShowWarmUp: Bool
            let warmUpLeftHours: Int
            let warmUpLeftMinutes: Int
        }
    }
}
