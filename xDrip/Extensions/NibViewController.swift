//
//  NibViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 01.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class NibViewController: UIViewController, NibLoadable {
    required init() {
        super.init(nibName: Self.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension UIViewController {
    func embed<T: NibViewController>(_ type: T.Type, in view: UIView) {
        let viewController = T()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.willMove(toParent: self)
        addChild(viewController)
        viewController.didMove(toParent: self)
        
        viewController.loadViewIfNeeded()
        view.addSubview(viewController.view)
        viewController.view.bindToSuperview()
    }
}

protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable where Self: UIViewController {
    static var nibName: String {
        return String(describing: self)
    }
}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }
    
    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }
    
    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView
            else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
