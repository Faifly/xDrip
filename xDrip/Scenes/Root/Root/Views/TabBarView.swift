//
//  TabBarView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class TabBarView: UIView {
    @IBOutlet private weak var calibrationButton: UIButton!
    @IBOutlet private weak var chartButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var historyButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    
    var itemSelectionHandler: ((Root.TabButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [calibrationButton, chartButton, plusButton, historyButton, settingsButton].forEach { (button) in
            button?.centerVertically()
        }
    }
    
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
