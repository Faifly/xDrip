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
        self.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurEffectView, at: 0)
    }
}
