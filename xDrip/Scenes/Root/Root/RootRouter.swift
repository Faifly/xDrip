//
//  RootRouter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol RootRoutingLogic {
    func routeToCalibration()
    func routeToStats()
    func routeToHistory()
    func routeToSettings()
    
    func routeToAddFood()
    func routeToAddBolus()
    func routeToAddCarbs()
    func routeToInitialSetup()
    
    func showCalibrationError(title: String, message: String)
}

protocol RootDataPassing {
    var dataStore: RootDataStore? { get }
}

final class RootRouter: RootRoutingLogic, RootDataPassing {
    weak var viewController: RootViewController?
    weak var dataStore: RootDataStore?
    
    // MARK: Routing
    
    func routeToCalibration() {
        presentViewController(EditCalibrationViewController())
    }
    
    func routeToStats() {
        presentViewController(StatsRootViewController())
    }
    
    func routeToHistory() {
        presentViewController(HistoryRootViewController())
    }
    
    func routeToSettings() {
        let splitViewController = SettingsSplitViewController()
        splitViewController.viewControllers = [
            SettingsRootViewController().embedInNavigation(), SettingsChartViewController().embedInNavigation()
        ]
        
        #if targetEnvironment(macCatalyst)
        splitViewController.modalPresentationStyle = .fullScreen
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            splitViewController.modalPresentationStyle = .fullScreen
        }
        #endif
        
        viewController?.present(splitViewController, animated: true)
    }
    
    func routeToAddFood() {
        routeToAddEntry(entryType: .food)
    }
    
    func routeToAddBolus() {
        routeToAddEntry(entryType: .bolus)
    }
    
    func routeToAddCarbs() {
        routeToAddEntry(entryType: .carbs)
    }
    
    func routeToInitialSetup() {
        let viewController = InitialSetupViewController()
        self.viewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func routeToAddEntry(entryType: Root.EntryType) {
        let editViewController = EditFoodEntryViewController()
        guard let dataStore = editViewController.router?.dataStore else {
            return
        }
        
        switch entryType {
        case .food: dataStore.entryType = .food
        case .bolus: dataStore.entryType = .bolus
        case .carbs: dataStore.entryType = .carbs
        default:
            break
        }
        
        presentViewController(editViewController)
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        self.viewController?.present(viewController.embedInNavigation(), animated: true, completion: nil)
    }
    
    func showCalibrationError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localized, style: .cancel)
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
