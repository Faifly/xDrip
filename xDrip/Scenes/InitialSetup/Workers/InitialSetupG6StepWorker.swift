//
//  InitialSetupG6StepWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum InitialSetupG6Step: InitialSetupStep {
    case deviceID
    case sensorAge
    case connect
    case warmUp
    
    func createViewController() -> InitialSetupInteractable {
        switch self {
        case .deviceID: return InitialSetupG6DeviceIDViewController()
        case .sensorAge: return InitialSetupG6SensorAgeViewController()
        case .connect: return InitialSetupG6ConnectViewController()
        case .warmUp: return InitialSetupG6WarmUpViewController()
        }
    }
}

final class InitialSetupG6StepWorker: InitialSetupStepProvidingWorker {
    private var currentStep: InitialSetupG6Step = .deviceID
    
    func completeStep(_ step: InitialSetupStep) {
        guard let step = step as? InitialSetupG6Step else { return }
        switch step {
        case .deviceID: currentStep = .connect
        case .sensorAge: currentStep = .warmUp
        case .connect: currentStep = .sensorAge
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
