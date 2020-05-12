//
//  BaseSettingsPickerExpandableTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class PickerExpandableTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var verticalStackView: UIStackView!
    @IBOutlet weak private var mainTextLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    
    private var picker: PickerView?
    
    func configure(mainText: String, detailText: String?, pickerView: PickerView, isExpanded: Bool) {
        mainTextLabel.text = mainText
        detailLabel.text = detailText
        picker = pickerView
        
        picker?.onValueChanged = { [weak self] detailString in
            self?.detailLabel.text = detailString
        }
        
        verticalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if isExpanded {
            guard let picker = picker else { return }
            verticalStackView.addArrangedSubview(picker)
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
