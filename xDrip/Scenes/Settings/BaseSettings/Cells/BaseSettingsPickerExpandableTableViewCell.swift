//
//  BaseSettingsPickerExpandableTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsPickerExpandableTableViewCell: UITableViewCell {
    @IBOutlet private weak var verticalStackView: UIStackView!
    @IBOutlet private weak var mainTextLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    private var picker: BaseSettingsPickerView?
    
    func configure(mainText: String, detailText: String?, pickerView: BaseSettingsPickerView) {
        mainTextLabel.text = mainText
        detailLabel.text = detailText
        picker = pickerView
        
        picker?.onValueChanged = { [weak self] detailString in
            self?.detailLabel.text = detailString
        }
    }
    
    func togglePickerVisivility() {
        guard let picker = picker else { return }
        
        if verticalStackView.arrangedSubviews.contains(picker) {
            picker.removeFromSuperview()
        } else {
            verticalStackView.addArrangedSubview(picker)
        }
    }
}
