//
//  BaseSettingsRightSwitchTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 10.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseSettingsRightSwitchTableViewCell: UITableViewCell {
    private var rightSwitch = UISwitch()
    
    var valueChangedHandler: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryView = rightSwitch
        rightSwitch.sizeToFit()
    }
    
    func configurate(mainText: String, isSwitchOn: Bool) {
        textLabel?.text = mainText
        rightSwitch.setOn(isSwitchOn, animated: true)
    }
    
    @objc func switchValueChanged() {
        let value = rightSwitch.isOn
        valueChangedHandler?(value)
    }
}
