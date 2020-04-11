//
//  BaseSettingsVolumeSliderTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseSettingsVolumeSliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var slider: UISlider!
    
    var onSliderValueChanged: ((Float) -> Void)?
    
    func configure(value: Float) {
        slider.setValue(value, animated: true)
    }
    
    @IBAction func onValueChanged(_ sender: UISlider) {
        onSliderValueChanged?(sender.value)
    }
}
