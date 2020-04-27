//
//  BaseSettingsTextInputTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsTextInputTableViewCell: UITableViewCell {

    @IBOutlet weak private var mainTextLabel: UILabel!
    @IBOutlet weak private var textField: UITextField!
    
    private var textChangeHandler: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }
    
    func configure(mainText: String, detailText: String?, textChangeHandler: ((String?) -> Void)?) {
        mainTextLabel.text = mainText
        textField.placeholder = detailText
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
