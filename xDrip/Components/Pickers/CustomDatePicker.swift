//
//  CustomDatePicker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CustomDatePicker: UIDatePicker, PickerView {
    
    var onValueChanged: ((String?) -> Void)?
    var formatDate: ((Date) -> (String))?
    
    init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
        
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 13.4, *) {
            preferredDatePickerStyle = .wheels
        }
        #endif
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
        
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 13.4, *) {
            preferredDatePickerStyle = .wheels
        }
        #endif
    }
    
    @objc private func handleValueChanged() {
        let formattedValue = formatDate?(date)
        onValueChanged?(formattedValue)
    }
}
