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
        
        inject(
            formattingWorker: formattingWorker,
            persistenceWorker: persistenceWorker,
            for: viewController
        )
    }
    
    func configureSceneForBolus(_ viewController: EntriesListViewController) {
        let persistenceWorker = EntriesListBolusPersistenceWorker()
        let formattingWorker = EntriesListBolusFormattingWorker()
        
        viewController.title = "entries_list_scene_title_bolus".localized
        
        inject(
            formattingWorker: formattingWorker,
            persistenceWorker: persistenceWorker,
            for: viewController
        )
    }
    
    private func inject(formattingWorker: EntriesListFormattingWorker,
                        persistenceWorker: EntriesListEntryPersistenceWorker,
                        for viewController: EntriesListViewController) {
        
        let interactor = viewController.interactor
        let presenter = interactor?.presenter
        
        interactor?.inject(persistenceWorker: persistenceWorker)
        presenter?.inject(formattingWorker: formattingWorker)
    }
}
