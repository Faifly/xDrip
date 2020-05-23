//
//  SettingsTransmitterPresenter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsTransmitterPresentationLogic {
    func presentLoad(response: SettingsTransmitter.Load.Response)
    func presentData(response: SettingsTransmitter.UpdateData.Response)
    func presentStatus(response: SettingsTransmitter.ChangeStatus.Response)
}

final class SettingsTransmitterPresenter: SettingsTransmitterPresentationLogic {
    weak var viewController: SettingsTransmitterDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsTransmitter.Load.Response) {
        let viewModel = SettingsTransmitter.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func presentData(response: SettingsTransmitter.UpdateData.Response) {
        let infoSection = BaseSettings.Section.normal(
            cells: createInfoSectionCells(response: response),
            header: "settings_transmitter_info_section_header".localized,
            footer: nil
        )
        let batterySection = BaseSettings.Section.normal(
            cells: createBatteryInfoSectionCells(device: response.device),
            header: "settings_transmitter_battery_section_header".localized,
            footer: nil
        )
        
        let settingsViewModel = BaseSettings.ViewModel(sections: [infoSection, batterySection])
        let viewModel = SettingsTransmitter.UpdateData.ViewModel(viewModel: settingsViewModel)
        viewController?.displayData(viewModel: viewModel)
    }
    
    func presentStatus(response: SettingsTransmitter.ChangeStatus.Response) {
        let title: String?
        let backgroundColor: UIColor?
        let isEnabled: Bool
        let statusText: String?
        
        switch response.status {
        case .notSetup:
            title = "settings_transmitter_scan_button".localized
            backgroundColor = .tabBarBlueColor
            isEnabled = true
            statusText = "settings_transmitter_start_scanning_hint".localized
            
        case .initialSearch:
            title = "settings_transmitter_stop_scan_button".localized
            backgroundColor = .tabBarRedColor
            isEnabled = true
            statusText = "settings_transmitter_stop_scanning_hint".localized
            
        case .running(isConnectionActive: true):
            title = "settings_transmitter_updating_scan_button".localized
            backgroundColor = UIColor.tabBarBlueColor.withAlphaComponent(0.3)
            isEnabled = false
            statusText = "settings_transmitter_updating_hint".localized
            
        case .running(isConnectionActive: false):
            title = "settings_transmitter_stop_transmitter_button".localized
            backgroundColor = .tabBarRedColor
            isEnabled = true
            statusText = "settings_transmitter_unpair_hint".localized
        }
        
        let viewModel = SettingsTransmitter.ChangeStatus.ViewModel(
            title: title,
            backgroundColor: backgroundColor,
            isEnabled: isEnabled,
            statusText: statusText
        )
        viewController?.displayStatus(viewModel: viewModel)
    }
    
    // MARK: Logic
    
    private func createInfoSectionCells(response: SettingsTransmitter.UpdateData.Response) -> [BaseSettings.Cell] {
        let unknown = "settings_transmitter_no_value".localized
        
        let transmitterAgeString: String
        if let ageString = response.device.metadata(ofType: .transmitterTime)?.value, let age = Double(ageString) {
            transmitterAgeString = "\(Int(age / .secondsPerDay)) \("settings_transmitter_age_days".localized)"
        } else {
            transmitterAgeString = unknown
        }
        
        var cells: [BaseSettings.Cell] = [
            .info(
                mainText: "settings_transmitter_device_type_field".localized,
                detailText: CGMDeviceType.dexcomG6.name,
                detailTextColor: nil
            ),
            createSerialNumberCell(response: response),
            .info(
                mainText: "settings_transmitter_device_name_field".localized,
                detailText: response.device.metadata(ofType: .deviceName)?.value ?? unknown,
                detailTextColor: nil
            ),
            .info(
                mainText: "settings_transmitter_firmware_field".localized,
                detailText: response.device.metadata(ofType: .firmwareVersion)?.value ?? unknown,
                detailTextColor: nil
            ),
            .info(
                mainText: "settings_transmitter_device_age_field".localized,
                detailText: transmitterAgeString,
                detailTextColor: nil
            )
        ]
        
        if response.device.bluetoothID != nil {
            let resetTitle: String
            if response.device.isResetScheduled {
                resetTitle = "settings_transmitter_cancel_reset_button".localized
            } else {
                resetTitle = "settings_transmitter_reset_button".localized
            }
            cells.append(
                .button(
                    title: resetTitle,
                    color: response.device.isResetScheduled ? .tabBarBlueColor : .tabBarRedColor,
                    handler: response.resetHandler
                )
            )
        }
        
        return cells
    }
    
    private func createSerialNumberCell(response: SettingsTransmitter.UpdateData.Response) -> BaseSettings.Cell {
        let serialNumber = response.device.metadata(ofType: .serialNumber)?.value
        if response.allowSerialNumberChange {
            return .textInput(
                mainText: "settings_transmitter_serial_number_field".localized,
                detailText: serialNumber,
                placeholder: "settings_transmitter_serial_number_placeholder".localized,
                textChangedHandler: response.serialNumberChangeHandler
            )
        }
        
        return .info(
            mainText: "settings_transmitter_serial_number_field".localized,
            detailText: serialNumber,
            detailTextColor: nil
        )
    }
    
    private func createBatteryInfoSectionCells(device: CGMDevice) -> [BaseSettings.Cell] {
        let unknown = "settings_transmitter_no_value".localized
        
        let voltageA = createVoltage(value: device.metadata(ofType: .batteryVoltageA)?.value)
        let voltageB = createVoltage(value: device.metadata(ofType: .batteryVoltageB)?.value)
        
        let resistanceString = device.metadata(ofType: .batteryResistance)?.value ?? unknown
        let resistance: CGMDeviceResistance?
        if let resistanceValue = Int(resistanceString) {
            resistance = CGMDeviceResistance(value: resistanceValue)
        } else {
            resistance = nil
        }
        
        let batteryAgeString: String
        if let ageString = device.metadata(ofType: .batteryRuntime)?.value, let age = Double(ageString) {
            batteryAgeString = "\(Int(age)) \("settings_transmitter_age_days".localized)"
        } else {
            batteryAgeString = unknown
        }
        
        return [
            .info(
                mainText: "settings_transmitter_voltage_a_field".localized,
                detailText: voltageA.0,
                detailTextColor: voltageA.1?.color
            ),
            .info(
                mainText: "settings_transmitter_voltage_b_field".localized,
                detailText: voltageB.0,
                detailTextColor: voltageB.1?.color
            ),
            .info(
                mainText: "settings_transmitter_resistance_field".localized,
                detailText: resistanceString,
                detailTextColor: resistance?.color
            ),
            .info(
                mainText: "settings_transmitter_temperature_field".localized,
                detailText: formattedTemperature(value: device.metadata(ofType: .batteryTemperature)?.value),
                detailTextColor: nil
            ),
            .info(
                mainText: "settings_transmitter_runtime_field".localized,
                detailText: batteryAgeString,
                detailTextColor: nil
            )
        ]
    }
    
    private func createVoltage(value: String?) -> (String, CGMDeviceVoltage?) {
        let voltageString = value ?? "settings_transmitter_no_value".localized
        let voltage: CGMDeviceVoltage?
        if let voltageValue = Int(voltageString) {
            voltage = CGMDeviceVoltage(value: voltageValue)
        } else {
            voltage = nil
        }
        
        return (voltageString, voltage)
    }
    
    private func formattedTemperature(value: String?) -> String {
        if let temperatureString = value, let temperatureValue = Int(temperatureString) {
            let measurement = Measurement(value: Double(temperatureValue), unit: UnitTemperature.celsius)
            return MeasurementFormatter().string(from: measurement)
        }
        return "settings_transmitter_no_value".localized
    }
}

private extension CGMDeviceType {
    var name: String {
        switch self {
        case .dexcomG6: return "settings_transmitter_type_dexcom_g6".localized
        }
    }
}

private extension CGMDeviceVoltage {
    var color: UIColor {
        switch self {
        case .normal: return .tabBarGreenColor
        case .low: return .tabBarOrangeColor
        case .critical: return .tabBarRedColor
        }
    }
}

private extension CGMDeviceResistance {
    var color: UIColor {
        switch self {
        case .normal: return .tabBarGreenColor
        case .notice: return .tabBarOrangeColor
        case .critical: return .tabBarRedColor
        }
    }
}
