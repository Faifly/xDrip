//
//  SettingsUnitsInteractor.swift
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

protocol SettingsUnitsBusinessLogic {
    func doLoad(request: SettingsUnits.Load.Request)
}

protocol SettingsUnitsDataStore {
    
}

final class SettingsUnitsInteractor: SettingsUnitsBusinessLogic, SettingsUnitsDataStore {
    var presenter: SettingsUnitsPresentationLogic?
    var router: SettingsUnitsRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsUnits.Load.Request) {
        let user = User.current
        
        let response = SettingsUnits.Load.Response(currentSelectedUnit: user.settings.unit) { [weak self] (unit) in
            self?.handleUnitSelection(unit)
        }
        presenter?.presentLoad(response: response)
    }
    
    private func handleUnitSelection(_ unit: GlucoseUnit) {
        User.current.settings.updateUnit(unit)
        doLoad(request: SettingsUnits.Load.Request())
    }
}
