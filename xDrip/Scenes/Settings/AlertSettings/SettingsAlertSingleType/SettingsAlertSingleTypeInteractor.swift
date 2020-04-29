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

protocol SettingsAlertSingleTypeDataStore {
    var configuration: AlertConfiguration! { get set }
}

final class SettingsAlertSingleTypeInteractor: SettingsAlertSingleTypeBusinessLogic, SettingsAlertSingleTypeDataStore {
    var presenter: SettingsAlertSingleTypePresentationLogic?
    var router: SettingsAlertSingleTypeRoutingLogic?
    
    var configuration: AlertConfiguration!
    
    // MARK: Do something
    
    func doLoad(request: SettingsAlertSingleType.Load.Request) {
        configuration = User.current.settings.alert.customConfiguration(for: request.eventType)
        
        let response = createResponse(with: configuration)
        presenter?.presentLoad(response: response)
    }
    
    private func doUpdate() {
        let response = createResponse(with: configuration)
        presenter?.presentUpdate(response: response)
    }
    
    private func createResponse(with configuration: AlertConfiguration) -> SettingsAlertSingleType.Load.Response {
        return SettingsAlertSingleType.Load.Response(
            configuration: configuration,
            switchValueChangedHandler: { field, value in
                switch field {
                case .overrideDefault: configuration.updateIsEnabled(value); self.doUpdate()
                case .snoozeFromNotification: configuration.updateSnoozeFromNotification(value)
                case .repeat: configuration.updateRepeat(value)
                case .vibrate: configuration.updateIsVibrating(value)
                case .entireDay: configuration.updateIsEntireDay(value); self.doUpdate()
                default: break
                }
        }, textEditingChangedHandler: { string in
            configuration.updateName(string)
        }, timePickerValueChangedHandler: { field, value in
            switch field {
            case .defaultSnooze: configuration.updateDefaultSnooze(value)
            case .startTime: configuration.updateStartTime(value)
            case .endTime: configuration.updateEndTime(value)
            default: break
            }
        }, pickerViewValueChangedHandler: { field, value in
            switch field {
            case .highTreshold: configuration.updateHighThreshold(value)
            case .lowTreshold: configuration.updateLowThreshold(value)
            default: break
            }
        }, selectionHandler: {
            self.router?.routeToSound()
        })
    }
}
