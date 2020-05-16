//
//  MockedBluetoothService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 10.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class MockedBluetoothService {
    private weak var delegate: CGMBluetoothServiceDelegate?
    private var isStopped = false
    private var previousGlucoseValue: Double = 0.0
    
    init(delegate: CGMBluetoothServiceDelegate) {
        self.delegate = delegate
    }
    
    private func generateMetadata() {
        guard !isStopped else { return }
        
        delegate?.serviceDidUpdateMetadata(.batteryResistance, value: "1000")
        delegate?.serviceDidUpdateMetadata(.batteryRuntime, value: "22")
        delegate?.serviceDidUpdateMetadata(.batteryTemperature, value: "30")
        delegate?.serviceDidUpdateMetadata(.batteryVoltageA, value: "280")
        delegate?.serviceDidUpdateMetadata(.batteryVoltageB, value: "270")
        delegate?.serviceDidUpdateMetadata(.firmwareVersion, value: "01010101")
        delegate?.serviceDidUpdateMetadata(.transmitterTime, value: "22")
        delegate?.serviceDidUpdateMetadata(.transmitterVersion, value: "02020202")
    }
    
    private func generateGlucoseReading() {
        guard !isStopped else { return }
        
        let config = MockedBluetoothServiceConfiguration.current
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.glucoseReadingsInterval) { [weak self] in
                self?.generateGlucoseReading()
            }
        }
        
        let failed = Double.random(in: 0...100) < config.failProbability
        guard !failed else {
            delegate?.serviceDidFail(withError: .unknown)
            return
        }
        
        let deviationRange = config.glucoseMaximumEpsilon / 2.0
        let deviation = Double.random(in: -deviationRange...deviationRange)
        var nextValue = previousGlucoseValue + deviation
        
        switch config.glucoseChangeMode {
        case .normalDeviation: break
        case .continuousChange(let epsilon): nextValue += epsilon
        case .abnormalDeviation: nextValue += deviation
        }
        
        delegate?.serviceDidReceiveGlucoseReading(raw: nextValue, filtered: nextValue)
        previousGlucoseValue = nextValue
    }
}

extension MockedBluetoothService: CGMBluetoothService {
    func connect() {
        isStopped = false
        let config = MockedBluetoothServiceConfiguration.current
        previousGlucoseValue = config.initialGlucose
        DispatchQueue.main.asyncAfter(deadline: .now() + config.metadataReceiveDelay) { [weak self] in
            self?.generateMetadata()
            self?.generateGlucoseReading()
        }
    }
    
    func disconnect() {
        isStopped = true
    }
}
