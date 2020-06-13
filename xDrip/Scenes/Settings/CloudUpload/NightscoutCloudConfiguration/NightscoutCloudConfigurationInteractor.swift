//
//  NightscoutCloudConfigurationInteractor.swift
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

protocol NightscoutCloudConfigurationBusinessLogic {
    func doUpdateData(request: NightscoutCloudConfiguration.UpdateData.Request)
}

protocol NightscoutCloudConfigurationDataStore: AnyObject {
}

final class NightscoutCloudConfigurationInteractor: NightscoutCloudConfigurationBusinessLogic,
    NightscoutCloudConfigurationDataStore {
    var presenter: NightscoutCloudConfigurationPresentationLogic?
    var router: NightscoutCloudConfigurationRoutingLogic?
    
    private lazy var settings: NightscoutSyncSettings = {
        return User.current.settings.nightscoutSync ?? NightscoutSyncSettings()
    }()
    
    // MARK: Do something
    
    func doUpdateData(request: NightscoutCloudConfiguration.UpdateData.Request) {
        updateData()
    }
    
    private func handleSwitchValueChanged(_ field: NightscoutCloudConfiguration.Field, _ value: Bool) {
        switch field {
        case .enabled:
            settings.updateIsEnabled(value)
            
        case .useCellularData:
//            settings.updateUseCellularData(value)
            router?.presentNotYetImplementedAlert()
            
        case .sendDisplayGlucose:
//            settings.updateSendDisplayGlucose(value)
            router?.presentNotYetImplementedAlert()
            
        case .downloadData:
//            settings.updateDownloadData(value)
            router?.presentNotYetImplementedAlert()
            
        default: break
        }
        
        updateData()
    }
    
    private func handleTextEditingChanged(_ field: NightscoutCloudConfiguration.Field, _ string: String?) {
        if field == .baseURL {
            settings.updateBaseURL(string)
        } else if field == .apiSecret {
            settings.updateAPISecret(string)
        }
    }
    
    private func handleSingleSelection() {
        router?.routeToExtraOptions()
    }
    
    private func testConnection() {
        router?.showConnectionTestingAlert()
        NightscoutService.shared.testNightscoutConnection { [weak self] success, error in
            guard let self = self else { return }
            if success {
                guard let icon = UIImage(named: "icon_success") else { fatalError() }
                self.router?.finishConnectionTestingAlert(
                    message: "settings_nightscout_cloud_configuration_api_test_result_success".localized,
                    icon: icon
                )
            } else {
                guard let icon = UIImage(named: "icon_error") else { fatalError() }
                
                let message: String
                if let error = error {
                    switch error {
                    case .cantConnect, .invalidURL:
                        message = "settings_nightscout_cloud_configuration_api_test_result_invalid_server".localized
                    case .noAPISecret:
                        message = "settings_nightscout_cloud_configuration_api_test_result_no_secret".localized
                    case .invalidAPISecret:
                        message = "settings_nightscout_cloud_configuration_api_test_result_unauthorized".localized
                    }
                } else {
                    message = "error".localized
                }
                self.router?.finishConnectionTestingAlert(message: message, icon: icon)
            }
        }
    }
    
    private func updateData() {
        let response = NightscoutCloudConfiguration.UpdateData.Response(
            settings: settings,
            switchValueChangedHandler: handleSwitchValueChanged(_:_:),
            textEditingChangedHandler: handleTextEditingChanged(_:_:),
            singleSelectionHandler: handleSingleSelection,
            testConnectionHandler: testConnection
        )
        
        presenter?.presentData(response: response)
    }
}
