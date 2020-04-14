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
    
    private var picker = UIView()
    
    func configure(mainText: String, detailText: String?, pickerView: UIView) {
        mainTextLabel.text = mainText
        detailLabel.text = detailText
        picker = pickerView
        
        setupPickerView()
    }
    
    private func setupPickerView() {
        if let picker = picker as? UIPickerView {
            guard let controller = picker.delegate as? BaseSettingsPickerViewController else { return }
            controller.delegate = self
        } else if let picker = picker as? UIDatePicker {
            picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        }
    }
    
    func addPicker() {
        if verticalStackView.arrangedSubviews.contains(picker) {
            picker.removeFromSuperview()
        } else {
            verticalStackView.addArrangedSubview(picker)
        }
    }
    
    @objc private func dateChanged() {
        guard let picker = picker as? UIDatePicker else { return }
        
        let date = DateFormatter.localizedString(from: picker.date, dateStyle: .short, timeStyle: .short)
        detailLabel.text = date
    }
}

extension BaseSettingsPickerExpandableTableViewCell: BaseSettingsPickerViewDelegate {
    func pickerValueChanged(selectedValues: [String]) {
        let formattedString = selectedValues.joined(separator: " ")
        
        detailLabel.text = formattedString
    }
}
