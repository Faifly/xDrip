//
//  InitialSetupIntroViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupIntroViewController: InitialSetupAbstractStepViewController {
    @IBOutlet private weak var startFlowButton: UIButton!
    @IBOutlet private weak var largeTitleLable: UILabel!
    
    @IBAction private func onBeginSetup() {
        let request = InitialSetup.BeginSetup.Request()
        interactor?.doBeginSetup(request: request)
    }
    
    @IBAction private func onSkipSetup() {
        let request = InitialSetup.SkipSetup.Request()
        interactor?.doSkipSetup(request: request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_welcome_screen_title".localized
        var title = "initial_welcome_large_welcome_message".localized
        
        #if targetEnvironment(macCatalyst)
        title += "macOS!"
        #else
        title += "iOS!"
        #endif
        
        largeTitleLable.text = title
    }
}
