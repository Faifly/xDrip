//
//  SettingsPumpUserViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsPumpUserDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsPumpUser.Load.ViewModel)
    func displayState(viewModel: SettingsPumpUser.UpdateState.ViewModel)
}

class SettingsPumpUserViewController: NibViewController, SettingsPumpUserDisplayLogic {
    var interactor: SettingsPumpUserBusinessLogic?
    var router: SettingsPumpUserDataPassing?
    
    // MARK: Object lifecycle
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use regular init")
    }
    
    required init() {
        super.init()
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = SettingsPumpUserInteractor()
        let presenter = SettingsPumpUserPresenter()
        let router = SettingsPumpUserRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var syncButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doLoad()
    }
    
    // MARK: Do something
    
    private var viewModel: SettingsPumpUser.UpdateState.ViewModel?
    
    private func doLoad() {
        let request = SettingsPumpUser.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupUI() {
        infoLabel.text = "settings_pump_user_info_label_text".localized
        tableView.registerNib(type: BaseSettingsDisclosureCell.self)
    }
    
    private func displayNonSynced() {
        infoLabel.isHidden = false
        tableView.isHidden = true
        syncButton.setTitle("settings_pump_user_sync_button_title".localized, for: .normal)
        syncButton.backgroundColor = .customBlue
    }
    
    private func displaySynced(viewModel: SettingsPumpUser.UpdateState.ViewModel) {
        infoLabel.isHidden = true
        tableView.isHidden = false
        syncButton.setTitle("settings_pump_user_unpair_button_title".localized, for: .normal)
        syncButton.backgroundColor = .tabBarRedColor
        
        self.viewModel = viewModel
        tableView.reloadData()
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsPumpUser.Load.ViewModel) {
    }
    
    func displayState(viewModel: SettingsPumpUser.UpdateState.ViewModel) {
        if viewModel.isSynced {
            displaySynced(viewModel: viewModel)
        } else {
            displayNonSynced()
        }
    }
    
    // MARK: Handlers
    
    @IBAction private func onSync(_ sender: UIButton) {
        let request = SettingsPumpUser.Sync.Request()
        interactor?.doSync(request: request)
    }
}

extension SettingsPumpUserViewController: UITableViewDataSource, UITableViewDelegate {
    private enum CellType: Int, CaseIterable {
        case nightscoutURL
        case pumpID
        case manufacturer
        case model
        case connectionDate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: BaseSettingsDisclosureCell.self, for: indexPath)
        switch CellType.allCases[indexPath.row] {
        case .nightscoutURL:
            cell.configure(
                mainText: "settings_pump_user_nightscout_url_cell_title".localized,
                detailText: viewModel?.nightscoutURL,
                showDisclosureIndicator: false,
                detailTextColor: nil,
                isLoading: false
            )
            
        case .pumpID:
            cell.configure(
                mainText: "settings_pump_user_pump_id_cell_title".localized,
                detailText: viewModel?.pumpID,
                showDisclosureIndicator: false,
                detailTextColor: nil,
                isLoading: false
            )
            
        case .manufacturer:
            cell.configure(
                mainText: "settings_pump_user_pump_manufacturer_cell_title".localized,
                detailText: viewModel?.manufacturer,
                showDisclosureIndicator: false,
                detailTextColor: nil,
                isLoading: false
            )
            
        case .model:
            cell.configure(
                mainText: "settings_pump_user_pump_model_cell_title".localized,
                detailText: viewModel?.model,
                showDisclosureIndicator: false,
                detailTextColor: nil,
                isLoading: false
            )
            
        case .connectionDate:
            cell.configure(
                mainText: "settings_pump_user_pump_connection_date_cell_title".localized,
                detailText: viewModel?.connectionDate,
                showDisclosureIndicator: false,
                detailTextColor: nil,
                isLoading: false
            )
        }
        
        return cell
    }
}
