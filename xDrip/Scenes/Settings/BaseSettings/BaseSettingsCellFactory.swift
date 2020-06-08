//
//  BaseSettingsCellFactory.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

// swiftlint:disable function_body_length
// swiftling:disable cyclomatic_complexity

final class BaseSettingsCellFactory {
    weak var tableView: UITableView?
    
    var isCustomFoodType = false
    
    func createCell(ofType type: BaseSettings.Cell, indexPath: IndexPath, expandedCell: IndexPath?) -> UITableViewCell {
        guard let tableView = tableView else { fatalError() }
        
        switch type {
        case let .disclosure(mainText, detailText, _):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsDisclosureCell.self, for: indexPath)
            cell.configure(
                mainText: mainText,
                detailText: detailText,
                showDisclosureIndicator: true,
                detailTextColor: nil
            )
            return cell
            
        case let .info(mainText, detailText, detailTextColor):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsDisclosureCell.self, for: indexPath)
            cell.configure(
                mainText: mainText,
                detailText: detailText,
                showDisclosureIndicator: false,
                detailTextColor: detailTextColor
            )
            return cell
            
        case let .textInput(mainText, detailText, textFieldText, placeholder, keyboardType, textChangeHandler):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsTextInputTableViewCell.self, for: indexPath)
            cell.configure(
                mainText: mainText,
                detailText: detailText,
                textFieldText: textFieldText,
                placeholder: placeholder,
                keyboardType: keyboardType,
                textChangeHandler: textChangeHandler
            )
            
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
            let cell = tableView.dequeueReusableCell(
                ofType: PickerExpandableTableViewCell.self,
                for: indexPath
            )
            
            cell.configure(
                mainText: mainText,
                detailText: detailText,
                pickerView: picker,
                isExpanded: expandedCell == indexPath
            )
            
            return cell
            
        case let .button(title, color, handler):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsButtonCell.self, for: indexPath)
            cell.configure(title: title, titleColor: color, tapHandler: handler)
            return cell
        
        case let .foodType(handler):
            if isCustomFoodType {
                let cell = tableView.dequeueReusableCell(ofType: FoodTextInputTableViewCell.self, for: indexPath)
                cell.didEditingChange = handler
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(ofType: FoodTypeTableViewCell.self, for: indexPath)
                cell.didSelectFoodType = handler
                
                cell.didSelectCustomType = { [weak self] in
                    self?.isCustomFoodType = true
                    
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
                
                return cell
            }
        }
    }
    
    func createSingleSelectionCell(title: String, selectedIndex: Int, indexPath: IndexPath) -> UITableViewCell {
        guard let tableView = tableView else { fatalError() }
        
        let cell = tableView.dequeueReusableCell(ofType: BaseSettingsSingleSelectionTableViewCell.self, for: indexPath)
        cell.configure(mainText: title, selected: selectedIndex == indexPath.row)
        
        return cell
    }
}
