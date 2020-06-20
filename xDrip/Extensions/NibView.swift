//
//  NibView.swift
//  xDrip
//
//  Created by Dmitry on 6/18/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class NibView: UIView {
     static func instantiate<T: UIView>() -> T {
        let nib = UINib(nibName: className, bundle: Bundle(for: self))
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
            fatalError("View: \(className) couldn't be instantiated from nib")
        }
        return view
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        guard subviews.isEmpty else {
            return self
        }
        
        let currentClass = type(of: self)
        guard let view = Bundle(for: currentClass)
            .loadNibNamed(currentClass.className, owner: nil, options: nil)?
            .first as? UIView else {
                return self
        }
        
        view.frame = frame
        view.autoresizingMask = autoresizingMask
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        
        for constraint in constraints {
            var firstItem = constraint.firstItem
            if firstItem === (self as AnyObject?) {
                firstItem = view
            }
            var secondItem = constraint.secondItem
            if secondItem === (self as AnyObject?) {
                secondItem = view
            }
            
            if let firstItem = firstItem {
                view.addConstraint(NSLayoutConstraint(item: firstItem,
                                                      attribute: constraint.firstAttribute,
                                                      relatedBy: constraint.relation,
                                                      toItem: secondItem,
                                                      attribute: constraint.secondAttribute,
                                                      multiplier: constraint.multiplier,
                                                      constant: constraint.constant))
            }
        }
        
        return view
    }
}
