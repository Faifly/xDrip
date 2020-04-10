//
//  BaseSettingsViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseSettingsViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.bindToSuperview()
        
        tableView.registerNib(type: BaseSettingsDisclosureCell.self)
        
        return tableView
    }()
    
    private var viewModel: BaseSettings.ViewModel?
    private let cellFactory = BaseSettingsCellFactory()
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellFactory.tableView = tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    func update(with viewModel: BaseSettings.ViewModel, animated: Bool = false) {
        self.viewModel = viewModel
        if animated {
            // TODO: Implement
        } else {
            tableView.reloadData()
        }
    }
    
    private func handleSelectionForNormalCell(_ cell: BaseSettings.Cell) {
        switch cell {
        case .disclosure(_, _, let selectionHandler), .checkmark(_, _, let selectionHandler) :
            selectionHandler()
        default: break
        }
    }
    
    private func handleSingleSelection(indexPath: IndexPath, callback: (Int) -> Void) {
        // TODO: Implement
    }
}

extension BaseSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sections[section].rowsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { fatalError() }
        
        switch viewModel.sections[indexPath.section] {
        case .normal(let cells, _, _):
            return cellFactory.createCell(ofType: cells[indexPath.row], indexPath: indexPath)
            
        case .singleSelection(let cells, _, _, _):
            return cellFactory.createSingleSelectionCell(title: cells[indexPath.row], indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.sections[section].header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel?.sections[section].footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        let section = viewModel.sections[indexPath.section]
        switch section {
        case .normal(let cells, _, _):
            handleSelectionForNormalCell(cells[indexPath.row])
            
        case .singleSelection(_, _, _, let selectionHandler):
            handleSingleSelection(indexPath: indexPath, callback: selectionHandler)
        }
    }
}
