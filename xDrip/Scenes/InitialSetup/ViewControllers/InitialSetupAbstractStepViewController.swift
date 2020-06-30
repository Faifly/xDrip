//
//  InitialSetupAbstractStepViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol InitialSetupInteractable: UIViewController {
    var interactor: InitialSetupBusinessLogic? { get set }
}

class InitialSetupAbstractStepViewController: NibViewController, InitialSetupInteractable {
    var interactor: InitialSetupBusinessLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
}

class InitialSetupAbstractStepSettingsViewController: BaseSettingsViewController, InitialSetupInteractable {
    var interactor: InitialSetupBusinessLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
}
