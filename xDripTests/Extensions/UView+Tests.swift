//
//  UView+Tests.swift
//  xDrip
//
//  Created by Ivan Skoryk on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

extension UIView {
    func findView(with accessibilityID: String) -> UIView? {
        if accessibilityIdentifier == accessibilityID {
            return self
        }
        
        for subview in subviews {
            if let view = subview.findView(with: accessibilityID) {
                return view
            }
        }
        
        return nil
    }
}
