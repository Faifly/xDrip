//
//  LocalizedTextField.swift
//  xDrip
//
//  Created by Artem Kalmykov on 29.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class LocalizedTextField: UITextField {
    @IBInspectable var localizeText: Bool = false
    @IBInspectable var localizePlaceholder: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if localizeText {
            text = text?.localized
        }
        if localizePlaceholder {
            placeholder = placeholder?.localized
        }
    }
}
