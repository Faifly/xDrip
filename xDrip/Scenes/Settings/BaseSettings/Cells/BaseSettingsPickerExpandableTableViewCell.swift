//
//  BaseSettingsPickerExpandableTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

<<<<<<< HEAD
final class PickerExpandableTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var verticalStackView: UIStackView!
    @IBOutlet weak private var mainTextLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
=======
final class BaseSettingsPickerExpandableTableViewCell: UITableViewCell {
    @IBOutlet private weak var verticalStackView: UIStackView!
    @IBOutlet private weak var mainTextLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
>>>>>>> develop
    
    private var picker: PickerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        verticalStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func configure(mainText: String, detailText: String?, pickerView: PickerView) {
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
