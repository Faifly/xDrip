//
//  LocalizedButton.swift
//  xDrip
//
//  Created by Artem Kalmykov on 26.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class LocalizedButton: UIButton {
    @IBInspectable var localize: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if localize {
            setTitle(title(for: .normal)?.localized, for: .normal)
        }
    }
}
