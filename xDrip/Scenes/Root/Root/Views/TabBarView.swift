//
//  TabBarView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class TabBarView: UIView {
    @IBOutlet private weak var calibrationButton: CenteredTitleButton!
    @IBOutlet private weak var chartButton: CenteredTitleButton!
    @IBOutlet private(set) weak var plusButton: CenteredTitleButton!
    @IBOutlet private weak var historyButton: CenteredTitleButton!
    @IBOutlet private weak var settingsButton: CenteredTitleButton!
    
    var itemSelectionHandler: ((Root.TabButton) -> Void)?
    
    @IBAction private func onCalibrationButtonTap() {
        itemSelectionHandler?(.calibration)
    }
    
    @IBAction private func onChartButtonTap() {
        itemSelectionHandler?(.chart)
    }
    
    @IBAction private func onPlusButtonTap() {
        itemSelectionHandler?(.plus)
    }
    
    @IBAction private func onHistoryButtonTap() {
        itemSelectionHandler?(.history)
    }
    
    @IBAction private func onSettingsButtonTap() {
        itemSelectionHandler?(.settings)
    }
}
