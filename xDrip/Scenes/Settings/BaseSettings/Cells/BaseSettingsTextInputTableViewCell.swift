//
//  BaseSettingsTextInputTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsTextInputTableViewCell: UITableViewCell {
    @IBOutlet private weak var mainTextLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    private var textChangeHandler: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }
    
    func configure(
        mainText: String,
        detailText: String?,
        placeholder: String?,
        textChangeHandler: ((String?) -> Void)?) {
        mainTextLabel.text = mainText
        textField.text = detailText
        textField.placeholder = placeholder
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
