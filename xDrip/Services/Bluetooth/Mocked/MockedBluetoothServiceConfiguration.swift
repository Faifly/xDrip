//
//  MockedBluetoothServiceConfiguration.swift
//  xDrip
//
//  Created by Artem Kalmykov on 10.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct MockedBluetoothServiceConfiguration {
    static var current: MockedBluetoothServiceConfiguration = Predefined.quickUpdate.configuration
    
    enum GlucoseChangeMode {
        case normalDeviation
        case abnormalDeviation
        case continuousChange(epsilon: Double)
    }
    
    let metadataReceiveDelay: TimeInterval
    let glucoseReadingsInterval: TimeInterval
    let initialGlucose: Double
    let failProbability: Double
    let glucoseMaximumEpsilon: Double
    let glucoseChangeMode: GlucoseChangeMode
}

extension MockedBluetoothServiceConfiguration {
    enum Predefined {
        case dexcomG6Immitation
        case quickUpdate
        case fastRise
        case fastFall
        case abnormal
        case faily
    }
}

extension MockedBluetoothServiceConfiguration.Predefined {
    var configuration: MockedBluetoothServiceConfiguration {
        switch self {
        case .dexcomG6Immitation: return createDexcomG6ImmitationConfiguration()
        case .quickUpdate: return createQuickUpdateConfiguration()
        case .fastRise: return createFastRiseConfiguration()
        case .fastFall: return createFastFallConfiguration()
        case .abnormal: return createAbnormalConfiguration()
        case .faily: return createFailyConfiguration()
        }
    }
    
    private func createDexcomG6ImmitationConfiguration() -> MockedBluetoothServiceConfiguration {
        return MockedBluetoothServiceConfiguration(
            metadataReceiveDelay: 120.0,
            glucoseReadingsInterval: 300.0,
            initialGlucose: 100.0,
            failProbability: 0.01,
            glucoseMaximumEpsilon: 50.0,
            glucoseChangeMode: .normalDeviation
        )
    }
    
    private func createQuickUpdateConfiguration() -> MockedBluetoothServiceConfiguration {
        return MockedBluetoothServiceConfiguration(
            metadataReceiveDelay: 0.5,
            glucoseReadingsInterval: 300.0,
            initialGlucose: 110.0,
            failProbability: 0.0,
            glucoseMaximumEpsilon: 3.0,
            glucoseChangeMode: .normalDeviation
        )
    }
    
    private func createFastRiseConfiguration() -> MockedBluetoothServiceConfiguration {
        return MockedBluetoothServiceConfiguration(
            metadataReceiveDelay: 1.0,
            glucoseReadingsInterval: 10.0,
            initialGlucose: 50.0,
            failProbability: 0.0,
            glucoseMaximumEpsilon: 10.0,
            glucoseChangeMode: .continuousChange(epsilon: 50.0)
        )
    }
    
    private func createFastFallConfiguration() -> MockedBluetoothServiceConfiguration {
        return MockedBluetoothServiceConfiguration(
            metadataReceiveDelay: 1.0,
            glucoseReadingsInterval: 10.0,
            initialGlucose: 200.0,
            failProbability: 0.0,
            glucoseMaximumEpsilon: 10.0,
            glucoseChangeMode: .continuousChange(epsilon: -50.0)
        )
    }
    
    private func createAbnormalConfiguration() -> MockedBluetoothServiceConfiguration {
        return MockedBluetoothServiceConfiguration(
            metadataReceiveDelay: 1.0,
            glucoseReadingsInterval: 20.0,
            initialGlucose: 100.0,
            failProbability: 0.0,
            glucoseMaximumEpsilon: 1000.0,
            glucoseChangeMode: .abnormalDeviation
        )
    }
    
    private func createFailyConfiguration() -> MockedBluetoothServiceConfiguration {
        return MockedBluetoothServiceConfiguration(
            metadataReceiveDelay: 1.0,
            glucoseReadingsInterval: 60.0,
            initialGlucose: 1200.0,
            failProbability: 0.5,
            glucoseMaximumEpsilon: 100.0,
            glucoseChangeMode: .normalDeviation
        )
    }
}
