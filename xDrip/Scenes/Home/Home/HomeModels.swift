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

protocol BaseFoodEntryViewModel {
    var chartTitle: String { get }
    var chartButtonTitle: String { get }
    var entries: [BaseChartEntry] { get }
    var unit: String { get }
    var color: UIColor { get }
    var isShown: Bool { get }
    var isChartShown: Bool { get }
}

enum Home {
    // MARK: Models
    
    struct WarmUpState {
        let isWarmingUp: Bool
        let minutesLeft: Int?
    }
    
    enum SensorState {
        case stopped
        case warmingUp(minutesLeft: Int)
        case waitingReadings
        case started
    }
    
    struct DataSectionViewModel {
        let lowValue: String
        let lowTitle: String
        let inRange: String
        let highValue: String
        let highTitle: String
        let avgGlucose: String
        let a1c: String
        let reading: String
        let stdDeviation: String
        let gvi: String
        let pgs: String
        let isShown: Bool
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
            let glucoseData: [BaseGlucoseReading]
            let basalDisplayMode: ChartSettings.BasalDisplayMode
            let insulinData: [InsulinEntry]
            let chartPointsData: [InsulinEntry]
        }
        
        struct ViewModel {
            let glucoseValues: [GlucoseChartGlucoseEntry]
            let basalDisplayMode: ChartSettings.BasalDisplayMode
            let basalValues: [BasalChartBasalEntry]
            let strokeChartBasalValues: [BasalChartBasalEntry]
            let unit: String
        }
    }
    
    enum GlucoseDataViewUpdate {
        struct Request {
            let dateInterval: DateInterval
        }
        
        struct Response {
            let intervalGlucoseData: [BaseGlucoseReading]
        }
        
        struct ViewModel {
            let dataSection: DataSectionViewModel
        }
    }
    
    enum BolusDataUpdate {
        struct Request {
        }
        
        struct Response {
            let insulinData: [InsulinEntry]
            let isShown: Bool
        }
        
        struct ViewModel: BaseFoodEntryViewModel {
            let chartTitle: String
            let chartButtonTitle: String
            let entries: [BaseChartEntry]
            let unit: String
            let color: UIColor
            let isShown: Bool
            let isChartShown: Bool
        }
    }
        
    enum CarbsDataUpdate {
        struct Request {
        }
        
        struct Response {
            let carbsData: [CarbEntry]
            let isShown: Bool
        }
        
        struct ViewModel: BaseFoodEntryViewModel {
            let chartTitle: String
            let chartButtonTitle: String
            let entries: [BaseChartEntry]
            let unit: String
            let color: UIColor
            let isShown: Bool
            let isChartShown: Bool
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
    
    enum ChangeGlucoseEntriesChartTimeFrame {
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
    
    enum ChangeEntriesChartTimeFrame {
        struct Request {
            let hours: Int
        }
        
        struct Response {
            let timeInterval: TimeInterval
        }
        
        struct ViewModel {
            let timeInterval: TimeInterval
            let buttonTitle: String
            let isChartShown: Bool
        }
    }
    
    enum GlucoseCurrentInfo {
        struct Request {
        }
        
        struct Response {
            let lastGlucoseReading: BaseGlucoseReading?
        }
        
        struct ViewModel {
            let glucoseIntValue: String
            let glucoseDecimalValue: String
            let slopeValue: String
            let lastScanDate: String
            let difValue: String
            let severityColor: UIColor?
            let isOutdated: Bool
        }
    }
    
    enum UpdateSensorState {
        struct Response {
            let state: Home.SensorState
        }
        
        struct ViewModel {
            let shouldShow: Bool
            let text: NSAttributedString
        }
    }
}
