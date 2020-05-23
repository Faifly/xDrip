//
//  BaseSettingsDisclosureCell.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsDisclosureCell: UITableViewCell {
    func configure(mainText: String, detailText: String?, showDisclosureIndicator: Bool, detailTextColor: UIColor?) {
        textLabel?.text = mainText
        detailTextLabel?.text = detailText
        accessoryType = showDisclosureIndicator ? .disclosureIndicator : .none
        selectionStyle = showDisclosureIndicator ? .default : .none
        detailTextLabel?.textColor = detailTextColor ?? .mediumEmphasisText
    }
}
