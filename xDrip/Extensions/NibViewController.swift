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
