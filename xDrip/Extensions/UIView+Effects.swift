//
//  UIView+Custom.swift
//  xDrip
//
//  Created by Ivan Skoryk on 26.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

extension UIView {
    func addBlur() {
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurEffectView, at: 0)
    }
}
