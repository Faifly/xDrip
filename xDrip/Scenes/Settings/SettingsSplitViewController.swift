//
//  SplitViewController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 13.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class SettingsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        delegate = self
        preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
             _ splitViewController: UISplitViewController,
             collapseSecondary secondaryViewController: UIViewController,
             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
