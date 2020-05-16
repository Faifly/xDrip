//
//  BaseSettingsVolumeSliderTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsVolumeSliderTableViewCell: UITableViewCell {    
    @IBOutlet private weak var slider: UISlider!
    
    var onSliderValueChanged: ((Float) -> Void)?
    
    func configure(value: Float) {
        slider.setValue(value, animated: false)
    }
    
    @IBAction private func onValueChanged(_ sender: UISlider) {
        onSliderValueChanged?(sender.value)
    }
}
