//
//  TabBarView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class TabBarView: UIView {
    @IBOutlet private weak var homeButton: DualStateButton!
    @IBOutlet private weak var chartButton: DualStateButton!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var historyButton: DualStateButton!
    @IBOutlet private weak var settingsButton: UIButton!
}
