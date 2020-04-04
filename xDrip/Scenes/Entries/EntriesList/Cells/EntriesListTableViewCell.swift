//
//  EntriesListTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 27.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EntriesListTableViewCell: UITableViewCell, ViewModelConfigurable {
    struct ViewModel {
        let value: String
        let date: String
    }

    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueLabel.textColor = .timeFrameSegmentLabelColor
    }
    
    func configure(withViewModel viewModel: ViewModel) {
        valueLabel.text = viewModel.value
        dateLabel.text = viewModel.date
    }
}
