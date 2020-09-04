//
//  EntriesListSceneBuilder.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListSceneBuilder {
    func createSceneForCarbs() -> EntriesListViewController {
        let persistenceWorker = EntriesListCarbsPersistenceWorker()
        let formattingWorker = EntriesListCarbsFormattingWorker()
        
        let viewController = EntriesListViewController(
            persistenceWorker: persistenceWorker,
            formattingWorker: formattingWorker
        )
        viewController.title = "entries_list_scene_title_carbs".localized
        return viewController
    }
    
    func createSceneForBolus() -> EntriesListViewController {
        let persistenceWorker = EntriesListInsulinPersistenceWorker(type: .bolus)
        let formattingWorker = EntriesListInsulinFormattingWorker()
        
        let viewController = EntriesListViewController(
            persistenceWorker: persistenceWorker,
            formattingWorker: formattingWorker
        )
        viewController.title = "entries_list_scene_title_bolus".localized
        return viewController
    }
    
    func createSceneForTraining() -> EntriesListViewController {
        let persistenceWorker = EntriesListTrainingsPersistenceWorker()
        let formattingWorker = EntriesListTrainingsFormattingWorker()
        
        let viewController = EntriesListViewController(
            persistenceWorker: persistenceWorker,
            formattingWorker: formattingWorker
        )
        viewController.title = "entries_list_scene_title_trainings".localized
        return viewController
    }
    
    func createSceneForBasal() -> EntriesListViewController {
        let persistenceWorker = EntriesListInsulinPersistenceWorker(type: .basal)
        let formattingWorker = EntriesListInsulinFormattingWorker()
        
        let viewController = EntriesListViewController(
            persistenceWorker: persistenceWorker,
            formattingWorker: formattingWorker
        )
        viewController.title = "entries_list_scene_title_basals".localized
        return viewController
    }
}
