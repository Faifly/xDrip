//
//  EntriesListSceneBuilder.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListSceneBuilder {
    func configureSceneForCarbs(_ viewController: EntriesListViewController) {
        let persistenceWorker = EntriesListCarbsPersistenceWorker()
        let formattingWorker = EntriesListCarbsFormattingWorker()
        
        viewController.title = "entries_list_scene_title_carbs".localized
        
        guard let interactor = viewController.interactor as? EntriesListInteractor,
        let presenter = interactor.presenter as? EntriesListPresenter else { return }
        
        interactor.inject(persistenceWorker: persistenceWorker)
        presenter.inject(formattingWorker: formattingWorker)
    }
    
    func configureSceneForBolus(_ viewController: EntriesListViewController) {
        let persistenceWorker = EntriesListBolusPersistenceWorker()
        let formattingWorker = EntriesListBolusFormattingWorker()
        
        viewController.title = "entries_list_scene_title_bolus".localized
        
        guard let interactor = viewController.interactor as? EntriesListInteractor,
        let presenter = interactor.presenter as? EntriesListPresenter else { return }
        
        interactor.inject(persistenceWorker: persistenceWorker)
        presenter.inject(formattingWorker: formattingWorker)
    }
}
