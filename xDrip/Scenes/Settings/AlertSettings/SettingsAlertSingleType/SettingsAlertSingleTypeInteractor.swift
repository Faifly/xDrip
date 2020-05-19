//
//  SettingsAlertSingleTypeInteractor.swift
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

protocol SettingsAlertSingleTypeBusinessLogic {
    func doLoad(request: SettingsAlertSingleType.Load.Request)
}

protocol SettingsAlertSingleTypeDataStore: AnyObject {
    var eventType: AlertEventType? { get set }
    var configuration: AlertConfiguration { get set }
}

final class SettingsAlertSingleTypeInteractor: SettingsAlertSingleTypeBusinessLogic, SettingsAlertSingleTypeDataStore {
    var presenter: SettingsAlertSingleTypePresentationLogic?
    var router: SettingsAlertSingleTypeRoutingLogic?
    
    var eventType: AlertEventType?
    var configuration = AlertConfiguration()
    
    // MARK: Do something
    
    func doLoad(request: SettingsAlertSingleType.Load.Request) {
        let alertSettings = User.current.settings.alert
        configuration = alertSettings?.customConfiguration(for: eventType ?? .default) ?? AlertConfiguration()
        
        let response = SettingsAlertSingleType.Load.Response(
            animated: request.animated,
            configuration: configuration,
            switchValueChangedHandler: handleSwitchValueChanged(_:_:),
            textEditingChangedHandler: handleTextEditingChanged(_:),
            timePickerValueChangedHandler: handleTimePickerValueChanged(_:_:),
            pickerViewValueChangedHandler: handlePickerViewValueChanged(_:_:),
            selectionHandler: handleSelection
        )
        
        presenter?.presentLoad(response: response)
    }
    
    private func doUpdate() {
        doLoad(request: SettingsAlertSingleType.Load.Request(animated: true))
    }
    
    private func handleSwitchValueChanged(_ field: SettingsAlertSingleType.Field, _ value: Bool) {
        switch field {
        case .overrideDefault: configuration.updateIsEnabled(value); doUpdate()
        case .snoozeFromNotification: configuration.updateSnoozeFromNotification(value)
        case .repeat: configuration.updateRepeat(value)
        case .vibrate: configuration.updateIsVibrating(value)
        case .entireDay: configuration.updateIsEntireDay(value); doUpdate()
        default: break
        }
    }
    
    private func handleTextEditingChanged(_ string: String?) {
        configuration.updateName(string)
    }
    
    private func handleTimePickerValueChanged(_ field: SettingsAlertSingleType.Field, _ value: TimeInterval) {
        switch field {
        case .defaultSnooze: configuration.updateDefaultSnooze(value)
        case .startTime: configuration.updateStartTime(value)
        case .endTime: configuration.updateEndTime(value)
        default: break
        }
    }
    
    private func handlePickerViewValueChanged(_ field: SettingsAlertSingleType.Field, _ value: Double) {
        switch field {
        case .highTreshold: configuration.updateHighThreshold(Float(value))
        case .lowTreshold: configuration.updateLowThreshold(Float(value))
        default: break
        }
    }
    
    private func handleSelection() {
        router?.routeToSound()
    }
}
