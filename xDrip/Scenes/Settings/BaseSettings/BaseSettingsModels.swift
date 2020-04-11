//
//  BaseSettingsModels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

enum BaseSettings {
    enum Cell {
        case disclosure(mainText: String, detailText: String?, selectionHandler: () -> Void)
        case textInput(mainText: String, detailText: String?, textChangedHandler: (String?) -> Void)
        case rightSwitch(text: String, isSwitchOn: Bool, switchHandler: (Bool) -> Void)
        case volumeSlider(value: Float, changeHandler: (Float) -> Void)
        case pickerExpandable(mainText: String, detailText: String?, dataSource: [[String]], picker: UIView)
    }
    
    enum Section {
        case normal(cells: [Cell], header: String?, footer: String?)
        case singleSelection(cells: [(String, Bool)], header: String?, footer: String?, selectionHandler: (Int) -> Void)
        
        var rowsCount: Int {
            switch self {
            case let .normal(cells, _, _): return cells.count
            case let .singleSelection(cells, _, _, _): return cells.count
            }
        }
        
        var header: String? {
            switch self {
            case .normal(_, let header, _): return header
            case .singleSelection(_, let header, _, _): return header
            }
        }
        
        var footer: String? {
            switch self {
            case .normal(_, _, let footer): return footer
            case .singleSelection(_, _, let footer, _): return footer
            }
        }
    }
    
    struct ViewModel {
        let sections: [Section]
    }
}
