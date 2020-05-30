//
//  StartSensorViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 29.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class StartSensorViewController: NibViewController {
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    var dateSavedHandler: ((Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "settings_start_sensor_screen_title".localized
        hintLabel.text = "settings_start_sensor_hint_label".localized
        datePicker.maximumDate = Date()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(onSave)
        )
    }
    
    @objc private func onSave() {
        dateSavedHandler?(datePicker.date)
        navigationController?.popViewController(animated: true)
    }
}
