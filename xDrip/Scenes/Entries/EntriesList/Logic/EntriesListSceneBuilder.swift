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
        let persistenceWorker = EntriesListInsulinPersistenceWorker()
        let formattingWorker = EntriesListInsulinFormattingWorker()
        
        let viewController = EntriesListViewController(
            persistenceWorker: persistenceWorker,
            formattingWorker: formattingWorker
        )
        viewController.title = "entries_list_scene_title_bolus".localized
        return viewController
    }
}
