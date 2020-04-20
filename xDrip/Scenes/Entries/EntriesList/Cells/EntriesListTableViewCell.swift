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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailTextLabel?.textColor = .lowEmphasisText
    }
    
    func configure(withViewModel viewModel: ViewModel) {
        textLabel?.text = viewModel.value
        detailTextLabel?.text = viewModel.date
    }
}
