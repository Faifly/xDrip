//
//  RootViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol RootDisplayLogic: class {
    func displayLoad(viewModel: Root.Load.ViewModel)
    func displayAddEntry(viewModel: Root.ShowAddEntryOptionsList.ViewModel)
}

class RootViewController: NibViewController, RootDisplayLogic {
    var interactor: RootBusinessLogic?
    var router: (NSObjectProtocol & RootRoutingLogic & RootDataPassing)?
    
    // MARK: Object lifecycle
    
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
        let interactor = RootInteractor()
        let presenter = RootPresenter()
        let router = RootRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    @IBOutlet private weak var tabBarContainer: TabBarView!
    @IBOutlet private weak var homeContainerView: UIView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let request = Root.InitialSetup.Request()
        interactor?.doShowInitialSetupIfNeeded(request: request)
    }
    
    // MARK: Do something
    
    private func doLoad() {
        setupUI()
        embed(HomeViewController.self, in: homeContainerView)
        
        let request = Root.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupUI() {
        tabBarContainer.itemSelectionHandler = { [weak self] tabButton in
            guard let self = self else { return }
            let request = Root.TabSelection.Request(button: tabButton)
            self.interactor?.doTabSelection(request: request)
        }
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: Root.Load.ViewModel) {
    }
    
    func displayAddEntry(viewModel: Root.ShowAddEntryOptionsList.ViewModel) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action: ((Int) -> ()) = { [weak self] entryIndex in
            guard let self = self else { return }
            let request = Root.ShowAddEntry.Request(index: entryIndex)
            self.interactor?.doShowAddEntry(request: request)
        }
        
        for (index, title) in viewModel.titles.enumerated() {
            let alertAction = UIAlertAction(title: title, style: .default) { _ in
                action(index)
            }
            alertController.addAction(alertAction)
        }
        
        alertController.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = tabBarContainer.plusButton
            popoverController.permittedArrowDirections = [.down]
        }
        
        present(alertController, animated: true)
    }
}
