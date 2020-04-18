//
//  BaseSettingsSingleSelectionTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsSingleSelectionTableViewCell: UITableViewCell {
    func configure(mainText: String, selected: Bool) {
        textLabel?.text = mainText
        accessoryType = selected ? .checkmark : .none
    }
}
