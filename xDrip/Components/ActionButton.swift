//
//  ActionButton.swift
//  xDrip
//
//  Created by Artem Kalmykov on 26.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ActionButton: LocalizedButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .tabBarBlueColor
        layer.cornerRadius = 5.0
        titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        setTitleColor(.white, for: .normal)
    }
}
