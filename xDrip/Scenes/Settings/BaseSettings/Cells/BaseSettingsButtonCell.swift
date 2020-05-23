//
//  BaseSettingsButtonCell.swift
//  xDrip
//
//  Created by Artem Kalmykov on 21.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsButtonCell: UITableViewCell {
    @IBOutlet private weak var button: UIButton!

    private var tapHandler: (() -> Void)?
    
    @IBAction private func onButtonTap() {
        tapHandler?()
    }
    
    func configure(title: String, titleColor: UIColor, tapHandler: @escaping () -> Void) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        self.tapHandler = tapHandler
    }
}
