//
//  BaseSettingsTextInputTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

//swiftlint:disable function_parameter_count

final class BaseSettingsTextInputTableViewCell: UITableViewCell {
    @IBOutlet private weak var mainTextLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var detailLabel: UILabel!
    
    private var textChangeHandler: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }
    
    func configure(
        mainText: String,
        detailText: String?,
        textFieldText: String?,
        placeholder: String?,
        keyboardType: UIKeyboardType,
        textChangeHandler: ((String?) -> Void)?) {
        mainTextLabel.text = mainText
        detailLabel.text = detailText
        textField.text = textFieldText
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        self.textChangeHandler = textChangeHandler
    }
    
    @IBAction private func editingChanged(_ sender: UITextField) {
        textChangeHandler?(sender.text)
    }
}

extension BaseSettingsTextInputTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
