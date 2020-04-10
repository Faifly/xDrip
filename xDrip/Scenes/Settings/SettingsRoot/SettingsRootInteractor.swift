//
//  SettingsRootInteractor.swift
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

protocol SettingsRootBusinessLogic {
    func doLoad(request: SettingsRoot.Load.Request)
    func doCancel(request: SettingsRoot.Cancel.Request)
}

protocol SettingsRootDataStore {
    
}

final class SettingsRootInteractor: SettingsRootBusinessLogic, SettingsRootDataStore {
    var presenter: SettingsRootPresentationLogic?
    var router: SettingsRootRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsRoot.Load.Request) {
        let user = User.current
        
        let response = SettingsRoot.Load.Response(
            deviceMode: user.settings.deviceMode,
            injectionType: user.settings.injectionType) { [weak self] field in
                self?.handleFieldSelection(field)
        }
        presenter?.presentLoad(response: response)
    }
    
    func doCancel(request: SettingsRoot.Cancel.Request) {
        router?.dismissSelf()
    }
    
    // MARK: Logic
    
    private func handleFieldSelection(_ field: SettingsRoot.Field) {
        switch field {
        case .units: router?.routeToUnits()
        default:
            break
        }
    }
}
