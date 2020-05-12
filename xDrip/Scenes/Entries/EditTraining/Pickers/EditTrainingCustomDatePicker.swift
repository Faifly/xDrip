//
//  EditTrainingCustomDatePicker.swift
//  xDrip
//
//  Created by Vladislav Kliutko on 24.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EditTrainingCustomDatePicker: UIDatePicker, EditTrainingPickerViewProtocol {
    
    var onValueChanged: ((String?) -> Void)?
    var formatDate: ((Date) -> (String))?
    
    init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
    }
    
    @objc private func handleValueChanged() {
        let formattedValue = formatDate?(date)
        onValueChanged?(formattedValue)
    }
}
