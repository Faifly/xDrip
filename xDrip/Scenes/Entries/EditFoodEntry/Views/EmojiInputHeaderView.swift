//
//  EmojiInputHeaderView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EmojiInputHeaderView: UICollectionReusableView {
    @IBOutlet private weak var titleLabel: UILabel!
    
    func setLabel(_ text: String) {
        titleLabel.text = text
    }
}
