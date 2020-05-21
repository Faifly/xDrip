//
//  ExpandableTableContainer.swift
//  xDrip
//
//  Created by Ivan Skoryk on 12.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol ExpandableTableContainer: UIViewController {
    var expandedCell: IndexPath? { get set }
    func toggleExpansion(indexPath: IndexPath, tableView: UITableView)
}

extension ExpandableTableContainer {
    func toggleExpansion(indexPath: IndexPath, tableView: UITableView) {
        let cell = tableView.cellForRow(at: indexPath) as? PickerExpandableTableViewCell
        
        cell?.togglePickerVisibility()
        
        if expandedCell == indexPath {
            expandedCell = nil
        } else {
            if let expandedIndexPath = expandedCell {
                let cell = tableView.cellForRow(at: expandedIndexPath) as? PickerExpandableTableViewCell
                cell?.togglePickerVisibility()
            }
            expandedCell = indexPath
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
