//
//  SettingsChartRangesViewController.swift
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

protocol SettingsChartRangesDisplayLogic: AnyObject {
    func displayUpdateData(viewModel: SettingsChartRanges.UpdateData.ViewModel)
}

class SettingsChartRangesViewController: BaseSettingsViewController, SettingsChartRangesDisplayLogic {
    var interactor: SettingsChartRangesBusinessLogic?
    var router: SettingsChartRangesDataPassing?
    
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
        let interactor = SettingsChartRangesInteractor()
        let presenter = SettingsChartRangesPresenter()
        let router = SettingsChartRangesRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsChartRanges.UpdateData.Request()
        interactor?.doUpdateData(request: request)
    }
    
    private func setupUI() {
        title = "settings_range_selection_scene_title".localized
    }
    
    // MARK: Display
    
    func displayUpdateData(viewModel: SettingsChartRanges.UpdateData.ViewModel) {
        update(with: viewModel.tableViewModel)
    }
}
