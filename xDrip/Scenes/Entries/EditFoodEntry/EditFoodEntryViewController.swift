//
//  EditFoodEntryViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EditFoodEntryDisplayLogic: AnyObject {
    func displayLoad(viewModel: EditFoodEntry.Load.ViewModel)
}

class EditFoodEntryViewController: NibViewController, EditFoodEntryDisplayLogic {
    var interactor: EditFoodEntryBusinessLogic?
    var router: EditFoodEntryDataPassing?
    
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
        let interactor = EditFoodEntryInteractor()
        let presenter = EditFoodEntryPresenter()
        let router = EditFoodEntryRouter()
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
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = EditFoodEntry.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: EditFoodEntry.Load.ViewModel) {
    }
}
