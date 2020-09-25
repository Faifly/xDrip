//
//  FoodTypeTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class FoodTypeTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var buttonStack: UIStackView!

    enum SelectionState: Int {
        case fast
        case medium
        case slow
        case custom
    }

    var selectionState = SelectionState.fast {
        didSet {
            updateButtons()
        }
    }

    var didSelectCustomType: (() -> Void)?
    var didSelectFoodType: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "edit_entry_type_of_food".localized
    }

    private func updateButtons() {
        for case (let index, let button as UIButton) in buttonStack.arrangedSubviews.enumerated() {
            button.isSelected = (index == selectionState.rawValue)
        }
    }

    @IBAction private func buttonTapped(_ sender: UIButton) {
        guard let index = buttonStack.arrangedSubviews.firstIndex(of: sender),
            let selection = SelectionState(rawValue: index)
        else {
            return
        }

        selectionState = selection
        
        if selection == .custom {
            didSelectCustomType?()
            didSelectFoodType?(nil)
            return
        }
        
        didSelectFoodType?(sender.currentTitle)
    }
}
