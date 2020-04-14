//
//  BaseSettingsPickerViewDataSource.swift
//  xDrip
//
//  Created by Ivan Skoryk on 14.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol BaseSettingsPickerViewDelegate: class {
    func pickerValueChanged(selectedValues: [String])
}

final class BaseSettingsPickerViewController: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let data: [[String]]
    
    weak var delegate: BaseSettingsPickerViewDelegate?
    
    init(data: [[String]]) {
        self.data = data
        super.init()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var values = [String]()
        
        for idx in 0 ..< pickerView.numberOfComponents {
            values.append(data[idx][pickerView.selectedRow(inComponent: idx)])
        }
        
        delegate?.pickerValueChanged(selectedValues: values)
    }
}
