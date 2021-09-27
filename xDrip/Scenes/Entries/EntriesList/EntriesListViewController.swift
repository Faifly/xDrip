//
//  EntriesListViewController.swift
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

protocol EntriesListDisplayLogic: AnyObject {
    func displayUpdateData(viewModel: EntriesList.UpdateData.ViewModel)
}

class EntriesListViewController: NibViewController, EntriesListDisplayLogic {
    var interactor: EntriesListBusinessLogic?
    var router: EntriesListDataPassing?
    
    // MARK: Object lifecycle
    
    required init(persistenceWorker: EntriesListEntryPersistenceWorker,
                  formattingWorker: EntriesListFormattingWorker) {
        super.init()
        setup(persistenceWorker: persistenceWorker, formattingWorker: formattingWorker)
    }
    
    @available(*, unavailable)
    required init() {
        fatalError("Use DI init")
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use DI init")
    }
    
    // MARK: Setup
    
    private func setup(persistenceWorker: EntriesListEntryPersistenceWorker,
                       formattingWorker: EntriesListFormattingWorker) {
        let viewController = self
        let interactor = EntriesListInteractor(persistenceWorker: persistenceWorker)
        let presenter = EntriesListPresenter(formattingWorker: formattingWorker)
        let router = EntriesListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    @IBOutlet private weak var tableView: UITableView!
    
    private let tableController = EntriesListTableController()
    private var isEdit = false
    private var sectionViewModels = [EntriesList.SectionViewModel]()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doUpdateData()
    }
    
    // MARK: Do something
    
    private func doUpdateData() {
        let request = EntriesList.UpdateData.Request()
        interactor?.doUpdateData(request: request)
    }
    
    @objc private func onCancelButtonTap() {
        let request = EntriesList.Cancel.Request()
        interactor?.doCancel(request: request)
    }
    
    @objc private func onEditButtonTap() {
        isEdit.toggle()
        setupRightBarButtonItem()
        tableView.isEditing = isEdit
    }
    
    // MARK: Display
    
    func displayUpdateData(viewModel: EntriesList.UpdateData.ViewModel) {
        sectionViewModels = viewModel.items
        
        tableController.tableView = tableView
        tableController.reload(with: viewModel.items)
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.editEnabled
    }
    
    private func setupUI() {
        if User.current.settings.deviceMode == .main {
            setupRightBarButtonItem()
        }
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "close".localized,
            style: .plain,
            target: self,
            action: #selector(onCancelButtonTap)
        )
    }
    
    private func setupRightBarButtonItem() {
        let item = UIBarButtonItem(
            barButtonSystemItem: isEdit ? .done : .edit,
            target: self,
            action: #selector(onEditButtonTap)
        )
        
        navigationItem.rightBarButtonItem = item
    }
    
    private func setupTableView() {
        tableView.allowsSelection = User.current.settings.deviceMode == .main
        
        tableController.didDeleteEntry = { [weak self] indexPath in
            guard let self = self else { return }
            
            self.sectionViewModels[indexPath.section].items.remove(at: indexPath.row)
            
            let request = EntriesList.DeleteEntry.Request(index: indexPath.row)
            self.interactor?.doDeleteEntry(request: request)
        }
        
        tableController.didSelectEntry = { [weak self] indexPath in
            guard let self = self else { return }
            let request = EntriesList.ShowSelectedEntry.Request(index: indexPath.row)
            self.interactor?.doShowSelectedEntry(request: request)
        }
    }
}
