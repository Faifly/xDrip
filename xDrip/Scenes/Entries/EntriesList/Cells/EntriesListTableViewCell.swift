//
//  EntriesListTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 27.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class EntriesListTableViewCell: UITableViewCell {

    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueLabel.textColor = UIColor.timeFrameSegmentLabelColor
    }
    
    func config(with model: EntriesList.CellViewModel) {
        valueLabel.text = model.value
        dateLabel.text = model.date
    }
}
