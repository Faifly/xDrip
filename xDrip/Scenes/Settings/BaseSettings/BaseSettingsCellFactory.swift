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
    
    func createCell(ofType type: BaseSettings.Cell, indexPath: IndexPath) -> UITableViewCell {
        guard let tableView = tableView else { fatalError() }
        
        switch type {
        case let .disclosure(mainText, detailText, _):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsDisclosureCell.self, for: indexPath)
            cell.configure(mainText: mainText, detailText: detailText)
            return cell
            
        case let .checkmark(mainText, selected, _):
            let cell = tableView.dequeueReusableCell(ofType: BaseSettingsDisclosureCell.self, for: indexPath)
            cell.configure(mainText: mainText, selected: selected)
            return cell
            
        case .textInput(_, _, _):
            // TODO: Implement
            fatalError()
            
        case .rightSwitch(_, _, _):
            // TODO: Implement
            fatalError()
            
        case .volumeSlider(_, _):
            // TODO: Implement
            fatalError()
            
        case .pickerExpandable(_, _, _):
            // TODO: Implement
            fatalError()
        }
    }
    
    func createSingleSelectionCell(title: String, indexPath: IndexPath) -> UITableViewCell {
        // TODO: Implement
        fatalError()
    }
}
