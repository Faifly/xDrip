//
//  HomeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import AKUtils

protocol HomeDisplayLogic: class {
    func displayLoad(viewModel: Home.Load.ViewModel)
}

class HomeViewController: UIViewController, HomeDisplayLogic {
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
    // MARK: Object lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    @IBOutlet weak var timeLineSegmentView: TimeFrameSelectionView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
        
        setupUI()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = Home.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    @IBAction func toEntriesList() {
        let request = Home.ShowEntriesList.Request(entriesType: Bool.random() ? .carbs : .bolus)
        interactor?.doShowEntriesList(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: Home.Load.ViewModel) {
        
    }
    
    private func setupUI() {
        let titles = [
            "home_time_frame_1h".localized,
            "home_time_frame_3h".localized,
            "home_time_frame_6h".localized,
            "home_time_frame_12h".localized,
            "home_time_frame_24h".localized
        ]
        
        timeLineSegmentView.config(with: titles)
        
        timeLineSegmentView.segmentChangedHandler = { (index) in
            // TO DO: - Handle segment changed
            print("TimeFrameSegmentDidChange index = \(index)")
        }
    }
}
