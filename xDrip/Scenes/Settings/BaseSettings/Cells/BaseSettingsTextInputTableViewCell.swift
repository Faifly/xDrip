//
//  BaseSettingsTextInputTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseSettingsTextInputTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    private var textChangeHandler: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }
    
    func configurate(mainText: String, detailText: String?, textChangeHandler: ((String?) -> Void)?) {
        mainTextLabel.text = mainText
        textField.placeholder = detailText
        self.textChangeHandler = textChangeHandler
    }
}

extension BaseSettingsTextInputTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textChangeHandler?(textField.text)
        return true
    }
}
