//
//  BaseSettingsModels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

// swiftlint:disable enum_case_associated_values_count

enum BaseSettings {
    enum Cell {
        case disclosure(mainText: String, detailText: String?, selectionHandler: () -> Void)
        case textInput(
            mainText: String,
            detailText: String?,
            placeholder: String?,
            textChangedHandler: (String?) -> Void
        )
        case rightSwitch(text: String, isSwitchOn: Bool, switchHandler: (Bool) -> Void)
        case volumeSlider(value: Float, changeHandler: (Float) -> Void)
        case pickerExpandable(mainText: String, detailText: String?, picker: PickerView)
        case button(title: String, color: UIColor, handler: () -> Void)
        case info(mainText: String, detailText: String?, detailTextColor: UIColor?)
    }
    
    enum Section {
        case normal(
            cells: [Cell],
            header: String?,
            footer: String?,
            attributedHeader: NSAttributedString? = nil,
            attributedFooter: NSAttributedString? = nil
        )
        case singleSelection(
            cells: [String],
            selectedIndex: Int,
            header: String?,
            footer: String?,
            selectionHandler: (Int) -> Void,
            attributedHeader: NSAttributedString? = nil,
            attributedFooter: NSAttributedString? = nil
        )
        
        var rowsCount: Int {
            switch self {
            case let .normal(cells, _, _, _, _): return cells.count
            case let .singleSelection(cells, _, _, _, _, _, _): return cells.count
            }
        }
        
        var header: String? {
            switch self {
            case .normal(_, let header, _, _, _): return header
            case .singleSelection(_, _, let header, _, _, _, _): return header
            }
        }
        
        var footer: String? {
            switch self {
            case .normal(_, _, let footer, _, _): return footer
            case .singleSelection(_, _, _, let footer, _, _, _): return footer
            }
        }
        
        var attributedHeader: NSAttributedString? {
            switch self {
            case .normal(_, _, _, let header, _): return header
            case .singleSelection(_, _, _, _, _, let header, _): return header
            }
        }
        
        var attributedFooter: NSAttributedString? {
            switch self {
            case .normal(_, _, _, _, let footer): return footer
            case .singleSelection(_, _, _, _, _, _, let footer): return footer
            }
        }
    }
    
    struct ViewModel {
        var sections: [Section]
    }
}
