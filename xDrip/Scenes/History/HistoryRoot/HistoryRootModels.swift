//
//  HistoryRootModels.swift
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

enum HistoryRoot {
    // MARK: Models
    
    enum Timeline {
        case last14Days
        case date
    }
    
    // MARK: Use cases
    
    enum Load {
        struct Request {
        }
        
        struct Response {
            let globalTimeInterval: TimeInterval
        }
        
        struct ViewModel {
            let globalTimeInterval: TimeInterval
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
    
    enum GlucoseDataUpdate {
        struct Request {
        }
        
        struct Response {
            let glucoseData: [BaseGlucoseReading]
            let intervalGlucoseData: [BaseGlucoseReading]
            let basalDisplayMode: ChartSettings.BasalDisplayMode
            let insulinData: [InsulinEntry]
            let chartPointsData: [InsulinEntry]
            let date: Date?
        }
        
        struct ViewModel {
            let glucoseValues: [GlucoseChartGlucoseEntry]
            let basalDisplayMode: ChartSettings.BasalDisplayMode
            let basalValues: [BasalChartBasalEntry]
            let strokeChartBasalValues: [BasalChartBasalEntry]
            let unit: String
            let dataSection: Home.DataSectionViewModel
            let date: Date?
        }
    }
    
    enum ChangeEntriesChartTimeFrame {
        struct Request {
            let timeline: Timeline
        }

        struct Response {
            let timeInterval: TimeInterval
        }

        struct ViewModel {
            let timeInterval: TimeInterval
        }
    }
    
    enum ChangeEntriesChartDate {
        struct Request {
            let date: Date
        }

        struct Response {
        }

        struct ViewModel {
        }
    }
}
