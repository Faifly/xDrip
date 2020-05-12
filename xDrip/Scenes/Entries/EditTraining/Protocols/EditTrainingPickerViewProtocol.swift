//
//  EditTrainingPickerViewProtocol.swift
//  xDrip
//
//  Created by Vladislav Kliutko on 24.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol EditTrainingPickerViewProtocol: UIView {
    var onValueChanged: ((String?) -> Void)? { get set }
}
