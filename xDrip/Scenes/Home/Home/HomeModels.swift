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
}

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
    
    enum BolusDataUpdate {
        struct Request {
        }
        
        struct Response {
            let bolusData: [InsulinEntry]
        }
        
        struct ViewModel: BaseFoodEntryViewModel {
            let chartTitle: String
            let chartButtonTitle: String
            let entries: [BaseChartEntry]
            let unit: String
            let color: UIColor
        }
    }
        
    enum CarbsDataUpdate {
        struct Request {
        }
        
        struct Response {
            let carbsData: [CarbEntry]
        }
        
        struct ViewModel: BaseFoodEntryViewModel {
            let chartTitle: String
            let chartButtonTitle: String
            let entries: [BaseChartEntry]
            let unit: String
            let color: UIColor
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
    
    enum ChangeEntriesChartTimeFrame {
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
