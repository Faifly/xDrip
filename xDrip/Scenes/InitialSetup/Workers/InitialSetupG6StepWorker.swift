//
//  InitialSetupG6StepWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class InitialSetupG6StepWorker: InitialSetupStepProvidingWorker {
    private var currentStep: InitialSetupG6Step = .deviceID
    
    func completeStep() {
        switch currentStep {
        case .deviceID: currentStep = .sensorAge
        case .sensorAge: currentStep = .connect
        case .connect: currentStep = .warmUp
        case .warmUp: break
        }
    }
    
    func initConnectionStep() {
        currentStep = .connect
    }
    
    var nextStep: InitialSetupStep? {
        return currentStep
    }
}

private enum InitialSetupG6Step: InitialSetupStep {
    case deviceID
    case sensorAge
    case connect
    case warmUp
    
    func createViewController() -> InitialSetupAbstractStepViewController {
        switch self {
        case .deviceID: return InitialSetupG6DeviceIDViewController()
        case .sensorAge: return InitialSetupG6SensorAgeViewController()
        case .connect: return InitialSetupG6ConnectViewController(connectionWorker: InitialSetupDexcomG6ConnectionWorker())
        case .warmUp: return InitialSetupG6WarmUpViewController()
        }
    }
}
