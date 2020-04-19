//
//  UIView+Bindings.swift
//  xDrip
//
//  Created by Ivan Skoryk on 23.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

extension UIView {
    func bindToSuperview(inset: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: inset.left).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -inset.right).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor, constant: inset.top).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -inset.bottom).isActive = true
    }
}
