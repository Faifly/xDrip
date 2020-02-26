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
}

final class RootViewController: UIViewController, RootDisplayLogic {
    var interactor: RootBusinessLogic?
    var router: (NSObjectProtocol & RootRoutingLogic & RootDataPassing)?
    
    // MARK: Object lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    @IBOutlet private weak var tabBarContainer: TabBarView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = Root.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: Root.Load.ViewModel) {
        
    }
}