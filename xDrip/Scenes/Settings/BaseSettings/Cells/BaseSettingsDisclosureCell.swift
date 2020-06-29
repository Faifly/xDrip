//
//  BaseSettingsDisclosureCell.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsDisclosureCell: UITableViewCell {
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 35.0, height: 35.0)
        return indicator
    }()
    
    func configure(mainText: String,
                   detailText: String?,
                   showDisclosureIndicator: Bool,
                   detailTextColor: UIColor?,
                   isLoading: Bool) {
        textLabel?.text = mainText
        detailTextLabel?.text = detailText
        if isLoading {
            accessoryType = .none
            activityIndicator.startAnimating()
            accessoryView = activityIndicator
        } else {
            activityIndicator.stopAnimating()
            accessoryView = nil
            accessoryType = showDisclosureIndicator ? .disclosureIndicator : .none
        }
        selectionStyle = showDisclosureIndicator ? .default : .none
        detailTextLabel?.textColor = detailTextColor ?? .mediumEmphasisText
    }
}
