//
//  InitialSetupInjectionTypeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupInjectionTypeViewController: InitialSetupAbstractStepViewController {
    @IBAction private func onPenTypeSelected() {
        let request = InitialSetup.SelectInjectionType.Request(injectionType: .pen)
        interactor?.doSelectInjectionType(request: request)
    }
    
    @IBAction private func onPumpTypeSelected() {
        let request = InitialSetup.SelectInjectionType.Request(injectionType: .pump)
        interactor?.doSelectInjectionType(request: request)
    }
}
