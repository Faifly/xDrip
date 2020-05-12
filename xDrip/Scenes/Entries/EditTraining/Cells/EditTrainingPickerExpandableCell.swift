//
//  EditTrainingDurationCell.swift
//  xDrip
//
//  Created by Vladislav Kliutko on 22.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class EditTrainingPickerExpandableCell: UITableViewCell {
    
    @IBOutlet weak private var verticalStackView: UIStackView!
    @IBOutlet weak private var mainTextLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    
    private var picker: EditTrainingPickerViewProtocol?
    
    func configure(mainText: String, detailText: String?, pickerView: EditTrainingPickerViewProtocol) {
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
