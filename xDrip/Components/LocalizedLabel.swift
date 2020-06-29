//
//  LocalizedLabel.swift
//  xDrip
//
//  Created by Artem Kalmykov on 26.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class LocalizedLabel: UILabel {
    @IBInspectable var localize: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if localize {
            text = text?.localized
        }
    }
}
