//
//  BaseSettingsDisclosureCell.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsDisclosureCell: UITableViewCell {
    func configure(mainText: String, detailText: String?) {
        textLabel?.text = mainText
        detailTextLabel?.text = detailText
    }
    
    func configure(mainText: String, selected: Bool) {
        textLabel?.text = mainText
        detailTextLabel?.text = nil
        accessoryType = selected ? .checkmark : .none
    }
}
