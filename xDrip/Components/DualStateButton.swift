//
//  DualStateButton.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class DualStateButton: UIButton {
    @IBInspectable private var selectedImage: UIImage?
    @IBInspectable private var deselectedImage: UIImage?
    
    var isSelectedState = false
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        setImage(selected ? selectedImage : deselectedImage, for: .normal)
    }
}
