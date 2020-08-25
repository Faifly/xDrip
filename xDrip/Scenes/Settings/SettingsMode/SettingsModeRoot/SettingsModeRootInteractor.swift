//
//  SettingsModeRootInteractor.swift
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

protocol SettingsModeRootBusinessLogic {
    func doLoad(request: SettingsModeRoot.Load.Request)
    func doChangeMode(request: SettingsModeRoot.ChangeMode.Request)
}

protocol SettingsModeRootDataStore: AnyObject {    
}

final class SettingsModeRootInteractor: SettingsModeRootBusinessLogic, SettingsModeRootDataStore {
    var presenter: SettingsModeRootPresentationLogic?
    var router: SettingsModeRootRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsModeRoot.Load.Request) {
        updateData()
    }
    
    func doChangeMode(request: SettingsModeRoot.ChangeMode.Request) {
        guard let nightscoutSettings = User.current.settings.nightscoutSync else { return }
        if request.mode == .main && nightscoutSettings.isFollowerAuthed {
            router?.presentSwitchingFromAuthorizedFollower { [weak self] confirmed in
                guard let self = self else { return }
                if confirmed {
                    User.current.settings.updateDeviceMode(.main)
                    User.current.settings.nightscoutSync?.updateIsFollowerAuthed(false)
                    NotificationCenter.default.postSettingsChangeNotification(setting: .deviceMode)
                }
                self.updateData()
            }
        } else {
            let settings = User.current.settings
            settings?.updateDeviceMode(request.mode)
            if request.mode == .follower {
                CGMController.shared.service?.disconnect()
            }
            
            NotificationCenter.default.postSettingsChangeNotification(setting: .deviceMode)
        }
    }
    
    private func updateData() {
        let mode = User.current.settings.deviceMode
        let response = SettingsModeRoot.Load.Response(mode: mode)
        presenter?.presentLoad(response: response)
    }
}
