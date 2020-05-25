//
//  BaseSettingsAttributtedTitleTableViewHeaderFooterView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 25.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsCustomTableViewHeaderFooterView: UITableViewHeaderFooterView {
    func configure(with attributedText: NSAttributedString) {
        textLabel?.attributedText = attributedText
    }
}
