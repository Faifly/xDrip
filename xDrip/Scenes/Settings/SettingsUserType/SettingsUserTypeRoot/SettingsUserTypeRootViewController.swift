//
//  SettingsUserTypeRootViewController.swift
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

protocol SettingsUserTypeRootDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsUserTypeRoot.Load.ViewModel)
}

class SettingsUserTypeRootViewController: NibViewController, SettingsUserTypeRootDisplayLogic {
    var interactor: SettingsUserTypeRootBusinessLogic?
    var router: SettingsUserTypeRootDataPassing?
    
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
        let interactor = SettingsUserTypeRootInteractor()
        let presenter = SettingsUserTypeRootPresenter()
        let router = SettingsUserTypeRootRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var containerView: UIView!
    
    private var embeddedTabBarController: UITabBarController?
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsUserTypeRoot.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupUI() {
        title = "settings_user_type_scene_title".localized
        
        let penViewController = SettingsPenUserViewController()
        let pumpViewController = SettingsPumpUserViewController()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [penViewController, pumpViewController]
        tabBarController.tabBar.isHidden = true
        
        tabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tabBarController.view)
        tabBarController.view.bindToSuperview()
        addChild(tabBarController)
        
        embeddedTabBarController = tabBarController
        
        let titles = UserInjectionType.allCases.map { $0.title }
        segmentedControl.removeAllSegments()
        titles.forEach {
            segmentedControl.insertSegment(
                withTitle: $0,
                at: segmentedControl.numberOfSegments,
                animated: false
            )
        }
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsUserTypeRoot.Load.ViewModel) {
        segmentedControl.selectedSegmentIndex = viewModel.injectionType.rawValue
        embeddedTabBarController?.selectedIndex = viewModel.injectionType.rawValue
    }
    
    // MARK: Handlers
    
    @IBAction private func onSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        embeddedTabBarController?.selectedIndex = sender.selectedSegmentIndex
        
        guard let type = UserInjectionType(rawValue: sender.selectedSegmentIndex) else { return }
        let request = SettingsUserTypeRoot.ChangeType.Request(injectionType: type)
        interactor?.doChangeType(request: request)
    }
}

private extension UserInjectionType {
    var title: String {
        switch self {
        case .pen: return "settings_user_type_pen_user".localized
        case .pump: return "settings_user_type_pump_user".localized
        }
    }
}
