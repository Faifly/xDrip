//
//  CustomTextField.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    var customInput: UIInputViewController?
    
    override var inputViewController: UIInputViewController? {
        return customInput
    }
}
