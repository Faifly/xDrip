//
//  GlucoseCurrentInfoView.swift
//  xDrip
//
//  Created by Dmitry on 6/16/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class GlucoseCurrentInfoView: NibView {
    @IBOutlet private weak var glucoseIntValueLabel: UILabel!
    @IBOutlet private weak var glucoseDecimalValueLablel: UILabel!
    @IBOutlet private weak var slopeArrowLabel: UILabel!
    @IBOutlet private weak var lastScanTitleLabel: UILabel!
    @IBOutlet private weak var lastScanValueLabel: UILabel!
    @IBOutlet private weak var difTitleLabel: UILabel!
    @IBOutlet private weak var difValueLabel: UILabel!
    
    func setup(with viewModel: Home.GlucoseCurrentInfo.ViewModel) {
        glucoseIntValueLabel.text = viewModel.glucoseIntValue
        glucoseIntValueLabel.textColor = viewModel.severityColor
        glucoseDecimalValueLablel.text = ". " + viewModel.glucoseDecimalValue
        glucoseDecimalValueLablel.textColor = viewModel.severityColor
        slopeArrowLabel.text = viewModel.slopeValue
        slopeArrowLabel.textColor = viewModel.severityColor
        lastScanTitleLabel.text = "home_last_scan_title".localized
        lastScanTitleLabel.textColor = .lastScanDateTextColor
        lastScanValueLabel.text = viewModel.lastScanDate
        difTitleLabel.text = "home_last_diff_title".localized
        difTitleLabel.textColor = .diffTextColor
        difValueLabel.text = viewModel.difValue
    }
}
