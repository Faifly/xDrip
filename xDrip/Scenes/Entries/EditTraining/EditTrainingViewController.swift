//
//  EditTrainingViewController.swift
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

protocol EditTrainingDisplayLogic: class {
    func displayLoad(viewModel: EditTraining.Load.ViewModel)
}

class EditTrainingViewController: NibViewController, EditTrainingDisplayLogic {
    var interactor: EditTrainingBusinessLogic?
    var dataStore: EditTrainingDataStore?
    
    private var viewModel: EditTraining.Load.ViewModel?
    
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
        let interactor = EditTrainingInteractor()
        let presenter = EditTrainingPresenter()
        let router = EditTrainingRouter()
        viewController.interactor = interactor
        viewController.dataStore = interactor
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    @IBOutlet weak private var tableView: UITableView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        setupNavigationItems()
        setupTableView()
        
        let request = EditTraining.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupNavigationItems() {
        var rightItem = UIBarButtonItem.SystemItem.done
        
        switch dataStore?.mode {
        case .edit( _ ):
            rightItem = .edit
        default:
            break
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: rightItem,
            target: self,
            action: #selector(onDoneButtonTap)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(onCancelButtonTap)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(type: EditTrainingPickerExpandableCell.self)
    }
    
    @objc
    private func onCancelButtonTap() {
        let request = EditTraining.Cancel.Request()
        interactor?.doCancel(request: request)
    }
    
    @objc
    private func onDoneButtonTap() {
        let request = EditTraining.Done.Request()
        interactor?.doDone(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: EditTraining.Load.ViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        tableView.reloadData()
    }
}

extension EditTrainingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.rowsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { fatalError() }
        
        let cellViewModel = viewModel.cells[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(ofType: EditTrainingPickerExpandableCell.self, for: indexPath)
        cell.configure(mainText: cellViewModel.mainText, detailText: cellViewModel.detailText, pickerView: cellViewModel.picker)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.headerTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EditTrainingPickerExpandableCell else { return }
        cell.togglePickerVisivility()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
