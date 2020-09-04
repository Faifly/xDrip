//
//  OptionsView.swift
//  xDrip
//
//  Created by Dmitry on 04.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

enum Option: Int {
    case allTrainings
    case allBasals
    
    var title: String {
        switch self {
        case .allTrainings:
            return "home_all_trainings".localized
        case .allBasals:
            return "home_all_basals".localized
        }
    }
}

class OptionsView: NibView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var optionsTableView: UITableView!
    
    private let cellFactory = BaseSettingsCellFactory()
    
    private let cells: [Option] = [.allTrainings, .allBasals]
    
    var itemSelectionHandler: ((Option) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        optionsTableView.registerNib(type: BaseSettingsDisclosureCell.self)
        cellFactory.tableView = optionsTableView
        optionsTableView.layer.cornerRadius = 5.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellType: BaseSettings.Cell
        switch cells[indexPath.row] {
        case .allTrainings:
            cellType = .disclosure(mainText: Option.allTrainings.title, detailText: nil, selectionHandler: {})
        case .allBasals:
            cellType = .disclosure(mainText: Option.allBasals.title, detailText: nil, selectionHandler: {})
        }
                
        let cell = cellFactory.createCell(
            ofType: cellType,
            indexPath: indexPath,
            expandedCell: nil
        )
        
        if indexPath.row == cells.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemSelectionHandler?(cells[indexPath.row])
    }
}
