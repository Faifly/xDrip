//
//  ChartRangesHeaderView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 27.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartRangesHeaderView: UIView {
    @IBOutlet private weak var ovalImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    
    func configure(with warningLevel: SettingsChartRanges.Field) {
        ovalImageView.image = warningLevel.icon
        headerLabel.text = warningLevel.sectionHeader
    }
}

private extension SettingsChartRanges.Field {
    var sectionHeader: String {
        switch self {
        case .notHigherLess: return "settings_range_selection_normal_section_header".localized
        case .highLow: return "setttings_range_selection_above_normal_section_header".localized
        case .urgent: return "settings_range_selection_urgent_section_header".localized
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .notHigherLess: return UIImage(named: "greenOval")
        case .highLow: return UIImage(named: "orangeOval")
        case .urgent: return UIImage(named: "redOval")
        }
    }
}
