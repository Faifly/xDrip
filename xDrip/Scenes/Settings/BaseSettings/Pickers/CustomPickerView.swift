//
//  CustomPickerView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CustomPickerView: UIPickerView, BaseSettingsPickerView {
    var onValueChanged: ((String?) -> Void)?
    var formatValues: (([String]) -> (String))?
    
    private let data: [[String]]
    
    init(data: [[String]]) {
        self.data = data
        
        super.init(frame: .zero)
        
        delegate = self
        dataSource = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
}

extension CustomPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        let formattedString = formatValues?(values)
        onValueChanged?(formattedString)
    }
}
