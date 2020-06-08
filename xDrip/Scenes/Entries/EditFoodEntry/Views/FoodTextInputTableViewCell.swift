//
//  FoodTextInputTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class FoodTextInputTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: CustomTextField!
    
    private var emojiController = EmojiInputViewController()
    
    var didEditingChange: ((String?) -> Void)?
    
    func setTextFieldFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "edit_food_entry_type_of_food".localized
        textField.delegate = self
        emojiController.delegate = self
        textField.customInput = emojiController
    }
    
    @IBAction private func textFieldEditingChanged(_ sender: Any) {
        didEditingChange?(textField.text)
    }
}

extension FoodTextInputTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FoodTextInputTableViewCell: EmojiInputControllerDelegate {
    func emojiInputControllerDidAdvanceToStandardInputMode(_ controller: EmojiInputViewController) {
        textField.customInput = nil
        textField.resignFirstResponder()
        textField.becomeFirstResponder()
        textField.customInput = emojiController
    }
}
