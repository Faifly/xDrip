//
//  BaseSettingsCellFactory.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BaseSettingsCellFactory {
    weak var tableView: UITableView?
    
    func createCell(ofType type: BaseSettings.Cell, indexPath: IndexPath, expandedCells: [IndexPath]) -> UITableViewCell {
        guard let tableView = tableView else { fatalError() }
        
        switch type {
        case let .disclosure(mainText, detailText, _):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsDisclosureCell.self, for: indexPath)
            cell.configure(mainText: mainText, detailText: detailText)
            return cell
            
        case let .textInput(mainText, detailText, placeholder, textChangeHandler):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsTextInputTableViewCell.self, for: indexPath)
            cell.configure(mainText: mainText, detailText: detailText, placeholder: placeholder, textChangeHandler: textChangeHandler)
            
            return cell
            
        case let .rightSwitch(mainText, isOn, handler):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsRightSwitchTableViewCell.self, for: indexPath)
            cell.configure(mainText: mainText, isSwitchOn: isOn)
            cell.valueChangedHandler = handler
            
            return cell
            
        case let .volumeSlider(value, valueChangeHandler):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsVolumeSliderTableViewCell.self, for: indexPath)
            cell.configure(value: value)
            cell.onSliderValueChanged = valueChangeHandler
            
            return cell
            
        case let .pickerExpandable(mainText, detailText, picker):
            let cell = tableView.dequeueReusableCell(ofType: PickerExpandableTableViewCell.self, for: indexPath)
            
            cell.configure(mainText: mainText, detailText: detailText, pickerView: picker, isExpanded: expandedCells.contains(indexPath))
            
            return cell
        }
    }
    
    func createSingleSelectionCell(title: String, selectedIndex: Int, indexPath: IndexPath) -> UITableViewCell {
        guard let tableView = tableView else { fatalError() }
        
        let cell = tableView.dequeueReusableCell(ofType: BaseSettingsSingleSelectionTableViewCell.self, for: indexPath)
        cell.configure(mainText: title, selected: selectedIndex == indexPath.row)
        
        return cell
    }
}
