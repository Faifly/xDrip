//
//  ExpandableTableContainer.swift
//  xDrip
//
//  Created by Ivan Skoryk on 12.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol ExpandableTableContainer: UIViewController {
    var expandedCells: [IndexPath] { get set }
    func toggleExpansion(indexPath: IndexPath, tableView: UITableView)
}

extension ExpandableTableContainer {
    func toggleExpansion(indexPath: IndexPath, tableView: UITableView) {
        
        let cell = tableView.cellForRow(at: indexPath) as? PickerExpandableTableViewCell
        
        cell?.togglePickerVisivility()
        
        if expandedCells.contains(indexPath) {
            if let index = expandedCells.firstIndex(of: indexPath) {
                expandedCells.remove(at: index)
            }
        } else {
            expandedCells.append(indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
