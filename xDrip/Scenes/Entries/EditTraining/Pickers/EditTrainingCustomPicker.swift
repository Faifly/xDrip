//
//  EditTrainingCustomPickerView.swift
//  xDrip
//
//  Created by Vladislav Kliutko on 24.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EditTrainingCustomPicker: UIPickerView, EditTrainingPickerViewProtocol {
    
    var onValueChanged: ((String?) -> Void)?
    var formatValues: (([String]) -> (String))?

    private let data: [[String]]
    
    init(data: [[String]]) {
        self.data = data
        
        super.init(frame: .zero)
        
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
}

extension EditTrainingCustomPicker: UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        for index in 0..<data.count {
            values.append(data[index][pickerView.selectedRow(inComponent: index)])
        }
        
        let formattedString = formatValues?(values)
        onValueChanged?(formattedString)
    }
}
