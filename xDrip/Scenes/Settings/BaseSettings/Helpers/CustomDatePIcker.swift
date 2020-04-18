//
//  CustomDatePIcker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CustomDatePicker: UIDatePicker, BaseSettingsPickerView {
    
    var onValueChanged: ((String?) -> Void)?
    var formatDate: ((Date) -> (String))?
    
    init() {
        super.init(frame: CGRect.zero)
        addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleValueChanged() {
        let formattedValue = formatDate?(date)
        onValueChanged?(formattedValue)
    }
}
