//
//  BaseSettingsViewControllerCoderTest.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 25.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
@testable import xDrip

final class BaseSettingsViewControllerCoderTest: BaseSettingsViewController {
    
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel.text = "Hello, World!"
    }
}
