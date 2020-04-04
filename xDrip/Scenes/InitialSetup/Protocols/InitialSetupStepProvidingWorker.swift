//
//  InitialSetupStepProvidingWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol InitialSetupStepProvidingWorker {
    func completeStep()
    func initConnectionStep()
    var nextStep: InitialSetupStep? { get }
}
