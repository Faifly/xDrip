//
//  BaseSettingsViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import AKUtils

class BaseSettingsViewController: UIViewController, ExpandableTableContainer {
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: tableViewStyle)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.bindToSuperview()
        
        tableView.registerNib(type: BaseSettingsDisclosureCell.self)
        tableView.registerNib(type: BaseSettingsSingleSelectionTableViewCell.self)
        tableView.registerNib(type: BaseSettingsRightSwitchTableViewCell.self)
        tableView.registerNib(type: BaseSettingsVolumeSliderTableViewCell.self)
        tableView.registerNib(type: PickerExpandableTableViewCell.self)
        tableView.registerNib(type: BaseSettingsTextInputTableViewCell.self)
        tableView.registerNib(type: BaseSettingsButtonCell.self)
        tableView.registerHeaderFooterView(type: BaseSettingsCustomTableViewHeaderFooterView.self)
        
        return tableView
    }()
    
    var tableViewStyle: UITableView.Style {
        if #available(iOS 13.0, *) {
            return .insetGrouped
        } else {
            return .grouped
        }
    }
    
    private var viewModel: BaseSettings.ViewModel?
    private let cellFactory = BaseSettingsCellFactory()
    var expandedCell: IndexPath?
    
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
            UIView.transition(
                with: tableView,
                duration: 0.35,
                options: .transitionCrossDissolve,
                animations: { self.tableView.reloadData() }
            )
        } else {
            tableView.reloadData()
        }
    }
    
    private func handleSelectionForNormalCell(_ cell: BaseSettings.Cell) {
        switch cell {
        case .disclosure(_, _, let selectionHandler):
            selectionHandler()
        default: break
        }
    }
    
    private func handleSingleSelection(indexPath: IndexPath, callback: (Int) -> Void) {
        guard let section = viewModel?.sections[indexPath.section] else { return }
        
        switch section {
        case let .singleSelection(cells, selectedIndex, header, footer, selectionHandler, attrHeader, attrFooter):
            
            if let previousCell = tableView.cellForRow(
                at: IndexPath(row: selectedIndex, section: indexPath.section)
                ) as? BaseSettingsSingleSelectionTableViewCell {
                previousCell.updateSelectionState(false)
            }
            
            if let nextCell = tableView.cellForRow(at: indexPath) as? BaseSettingsSingleSelectionTableViewCell {
                nextCell.updateSelectionState(true)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            viewModel?.sections[indexPath.section] = .singleSelection(
                cells: cells,
                selectedIndex: indexPath.row,
                header: header,
                footer: footer,
                selectionHandler: selectionHandler,
                attributedHeader: attrHeader,
                attributedFooter: attrFooter
            )
        default:
            break
        }
        
        callback(indexPath.row)
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
        case .normal(let cells, _, _, _, _):
            return cellFactory.createCell(
                ofType: cells[indexPath.row],
                indexPath: indexPath,
                expandedCell: expandedCell
            )
            
        case let .singleSelection(cells, selectedIndex, _, _, _, _, _):
            return cellFactory.createSingleSelectionCell(
                title: cells[indexPath.row],
                selectedIndex: selectedIndex,
                indexPath: indexPath
            )
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = viewModel?.sections[section].attributedHeader {
            let view = tableView.dequeReusableHeaderFooterView(ofType: BaseSettingsCustomTableViewHeaderFooterView.self)
            view?.configure(with: header)
            return view
        }
        
        if section == 0 {
            return viewModel?.sections[section].header == nil ? UIView() : nil
        } else {
            return nil
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
        case .normal(let cells, _, _, _, _):
            handleSelectionForNormalCell(cells[indexPath.row])
            
            switch cells[indexPath.row] {
            case .pickerExpandable:
                toggleExpansion(indexPath: indexPath, tableView: tableView)
            default:
                break
            }
            
        case .singleSelection(_, _, _, _, let selectionHandler, _, _):
            handleSingleSelection(indexPath: indexPath, callback: selectionHandler)
        }
    }
}

private extension UITableView {
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(type: T.Type) {
        register(type.self, forHeaderFooterViewReuseIdentifier: type.className)
    }
    
    func dequeReusableHeaderFooterView<T: UITableViewHeaderFooterView>(ofType type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: T.className) as? T
    }
}
