//
//  BaseSettingsPickerView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol BaseSettingsPickerView: UIView {
    var onValueChanged: ((String?) -> Void)? { get set }
}
