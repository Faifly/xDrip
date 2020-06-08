//
//  EmojiInputCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EmojiInputCell: UICollectionViewCell {
    @IBOutlet private weak var label: UILabel!
    
    func setLabel(_ text: String) {
        label.text = text
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateSelectionState()
        }
    }

    private func updateSelectionState() {
        let highlightColor: UIColor

        if #available(iOS 13.0, *) {
            highlightColor = .tertiarySystemFill
        } else {
            highlightColor = .white
        }

        backgroundColor = isSelected || isHighlighted ? highlightColor : nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 8
    }
}
