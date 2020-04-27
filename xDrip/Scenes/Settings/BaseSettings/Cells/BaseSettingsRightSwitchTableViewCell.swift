//
//  BaseSettingsRightSwitchTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 10.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsRightSwitchTableViewCell: UITableViewCell {
    private let rightSwitch = UISwitch()
    
    var valueChangedHandler: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryView = rightSwitch
        rightSwitch.sizeToFit()
        
        rightSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    func configure(mainText: String, isSwitchOn: Bool) {
        textLabel?.text = mainText
        rightSwitch.setOn(isSwitchOn, animated: false)
    }
    
    @objc private func switchValueChanged() {
        let value = rightSwitch.isOn
        valueChangedHandler?(value)
    }
}
