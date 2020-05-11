//
//  BaseSettingsPickerExpandableTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsPickerExpandableTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var verticalStackView: UIStackView!
    @IBOutlet weak private var mainTextLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    
    private var picker: BaseSettingsPickerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        verticalStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
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
