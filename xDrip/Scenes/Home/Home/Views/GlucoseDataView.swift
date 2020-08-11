//
//  GlucoseDataView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class GlucoseDataView: NibView {
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var valueLabels: [UILabel]!
    @IBOutlet private var containerViews: [UIView]!
    
    @IBOutlet private weak var lowValueLabel: UILabel!
    @IBOutlet private weak var inRangeValueLabel: UILabel!
    @IBOutlet private weak var highValueLabel: UILabel!
    @IBOutlet private weak var averageGlucoseValueLabel: UILabel!
    @IBOutlet private weak var a1cValueLabel: UILabel!
    @IBOutlet private weak var readingValueLabel: UILabel!
    @IBOutlet private weak var stdDeviationValueLabel: UILabel!
    @IBOutlet private weak var gviValueLabel: UILabel!
    @IBOutlet private weak var pgsValueLabel: UILabel!
    
    @IBOutlet private weak var lowTitleLabel: UILabel!
    @IBOutlet private weak var highTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 5.0

        titleLabels.forEach {
            $0.font = .systemFont(ofSize: 13.0, weight: .medium)
            $0.textColor = .highEmphasisText
        }
        valueLabels.forEach {
            $0.font = .systemFont(ofSize: 14.0, weight: .medium)
            $0.textColor = .mediumEmphasisText
        }
        containerViews.forEach { $0.backgroundColor = .background3 }
    }
}
