//
//  UIView+Bindings.swift
//  xDrip
//
//  Created by Ivan Skoryk on 23.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

extension UIView {
    func bindToSuperview() {
        guard let superview = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }
}
