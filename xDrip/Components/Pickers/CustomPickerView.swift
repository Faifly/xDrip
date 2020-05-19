//
//  CustomPickerView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CustomPickerView: UIPickerView, PickerView {
    enum Mode {
        case countDown
    }
    
    var onValueChanged: ((String?) -> Void)?
    var formatValues: (([String]) -> (String))?
    
    private let data: [[String]]
    
    init(data: [[String]]) {
        self.data = data
        
        super.init(frame: .zero)
        commonInit()
    }
    
    init(mode: Mode) {
        var data: [[String]] = []
        
        switch mode {
        case .countDown:
            let hours = stride(from: 0, to: 24, by: 1).map({ String($0) })
            let minutes = stride(from: 0, to: 60, by: 1).map({ String($0) })
            
            data = [
                hours,
                ["custom_picker_hours".localized],
                minutes,
                ["custom_picker_minutes".localized]
            ]
        }
        
        self.data = data
        
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
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
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 24)
        var maxWidth: CGFloat = 0.0
        
        for value in data[component] {
            let val = value as NSString
            let width = val.size(withAttributes: [NSAttributedString.Key.font: font]).width
            
            if width > maxWidth {
                maxWidth = width
            }
        }
        
        return maxWidth + 16.0
    }
}
