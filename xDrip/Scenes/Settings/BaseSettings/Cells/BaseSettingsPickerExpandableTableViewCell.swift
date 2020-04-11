//
//  BaseSettingsPickerExpandableTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseSettingsPickerExpandableTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var vertStackView: UIStackView!
    @IBOutlet weak private var mainTextLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    
    private var picker = UIView()
    private var dataSource = [[String]]()
    
    func configure(mainText: String, detailText: String?, dataSource: [[String]], pickerView: UIView) {
        mainTextLabel.text = mainText
        detailLabel.text = detailText
        picker = pickerView
        self.dataSource = dataSource
        
        setupPickerView()
    }
    
    private func setupPickerView() {
        if let picker = picker as? UIPickerView {
            picker.delegate = self
            picker.dataSource = self
            
            picker.reloadAllComponents()
        } else if let picker = picker as? UIDatePicker {
            picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        }
    }
    
    func addPicker() {
        if vertStackView.arrangedSubviews.contains(picker) {
            picker.removeFromSuperview()
        } else {
            vertStackView.addArrangedSubview(picker)
        }
    }
    
    @objc private func dateChanged() {
        guard let picker = picker as? UIDatePicker else { return }
        
        let date = DateFormatter.localizedString(from: picker.date, dateStyle: .short, timeStyle: .short)
        detailLabel.text = date
    }
}

extension BaseSettingsPickerExpandableTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var string = ""
        for i in 0 ..< pickerView.numberOfComponents {
            string += dataSource[i][pickerView.selectedRow(inComponent: i)] + " "
        }
        
        print(string)
        detailLabel.text = string
    }
}
