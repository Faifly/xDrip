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
    
    var isPaused = false
    
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
        delegate?.serviceDidUpdateMetadata(.firmwareVersion, value: "1.6.5.1")
        delegate?.serviceDidUpdateMetadata(.transmitterTime, value: "22")
        delegate?.serviceDidUpdateMetadata(.transmitterVersion, value: "1.6.5.1")
        delegate?.serviceDidUpdateMetadata(.deviceName, value: "Dexcom LK")
        CGMDevice.current.updateBluetoothID("123")
    }
    
    private func generateGlucoseReading() {
        guard !isStopped else { return }
        
        let config = MockedBluetoothServiceConfiguration.current
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.glucoseReadingsInterval) { [weak self] in
                self?.generateGlucoseReading()
            }
        }
        
        guard !isPaused else { return }
        
        let failed = Double.random(in: 0...100) < config.failProbability
        guard !failed else {
            delegate?.serviceDidFail(withError: .unknown)
            return
        }
        
        let deviationRange = config.glucoseMaximumEpsilon / 2.0
        let deviation = Double.random(in: -deviationRange...deviationRange) * 1000.0
        var nextValue = previousGlucoseValue + deviation
        
        switch config.glucoseChangeMode {
        case .normalDeviation: break
        case .continuousChange(let epsilon): nextValue += epsilon * 1000.0
        case .abnormalDeviation: nextValue += deviation
        }
        
        delegate?.serviceDidReceiveSensorGlucoseReading(raw: nextValue, filtered: nextValue, rssi: 100.0)
        previousGlucoseValue = nextValue
    }
}

extension MockedBluetoothService: CGMBluetoothService {
    func connect() {
        isStopped = false
        let config = MockedBluetoothServiceConfiguration.current
        previousGlucoseValue = config.initialGlucose * 1000.0
        DispatchQueue.main.asyncAfter(deadline: .now() + config.metadataReceiveDelay) { [weak self] in
            self?.generateMetadata()
            self?.generateGlucoseReading()
        }
    }
    
    func disconnect() {
        isStopped = true
    }
    
    func sendCalibration(glucose: Int, date: Date) {
    }
}
