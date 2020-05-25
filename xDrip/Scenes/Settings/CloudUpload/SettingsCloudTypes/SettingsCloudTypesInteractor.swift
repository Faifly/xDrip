//
//  SettingsCloudTypesInteractor.swift
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

protocol SettingsCloudTypesBusinessLogic {
    func doLoad(request: SettingsCloudTypes.Load.Request)
}

protocol SettingsCloudTypesDataStore: AnyObject {
}

final class SettingsCloudTypesInteractor: SettingsCloudTypesBusinessLogic, SettingsCloudTypesDataStore {
    var presenter: SettingsCloudTypesPresentationLogic?
    var router: SettingsCloudTypesRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsCloudTypes.Load.Request) {
        let response = SettingsCloudTypes.Load.Response(singleSelectionHandler: handleSingleSelection)
        presenter?.presentLoad(response: response)
    }
    
    private func handleSingleSelection() {
        router?.routeToNightscoutCloudConfiguration()
    }
}
