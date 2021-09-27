//
//  EntriesListTrainingsFormattingWorker.swift
//  xDrip
//
//  Created by Dmitry on 04.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListTrainingsFormattingWorker: EntriesListAbstractFormattingWorker, EntriesListFormattingWorker {
    func formatEntries(_ entries: [AbstractEntry]) -> [EntriesListTableViewCell.ViewModel] {
        let cellViewModels = entries.compactMap { transformToViewModel($0 as? TrainingEntry) }
        
        return cellViewModels
    }
    
    private func transformToViewModel(_ entry: TrainingEntry?) -> EntriesListTableViewCell.ViewModel? {
        guard let entry = entry else { return nil }
        
        let value = String(
            format: "%.0f " + "edit_entry_trainings_m".localized,
            entry.duration / TimeInterval.secondsPerMinute
        )
        let date = getDateString(for: entry)
        
        return EntriesListTableViewCell.ViewModel(value: value,
                                                  date: date,
                                                  isEnadled: User.current.settings.deviceMode == .main)
    }
}
