//
//  SettingsAlertSoundInteractor.swift
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

protocol SettingsAlertSoundBusinessLogic {
    func doLoad(request: SettingsAlertSound.Load.Request)
}

protocol SettingsAlertSoundDataStore: AnyObject {
    var configuration: AlertConfiguration? { get set }
}

final class SettingsAlertSoundInteractor: SettingsAlertSoundBusinessLogic, SettingsAlertSoundDataStore {
    var presenter: SettingsAlertSoundPresentationLogic?
    var router: SettingsAlertSoundRoutingLogic?
    
    var configuration: AlertConfiguration?
    
    // MARK: Do something
    
    func doLoad(request: SettingsAlertSound.Load.Request) {
        let response = SettingsAlertSound.Load.Response(
            selectedIndex: configuration?.soundID ?? 0,
            singleSelectionHandler: handleSingleSelection
        )
        presenter?.presentLoad(response: response)
    }
    
    private func handleSingleSelection(_ index: Int) {
        configuration?.updateSoundID(index)
        
        let sound = CustomSound.allCases[index]
        AudioController.shared.playSoundFile(sound.fileName)
    }
}
