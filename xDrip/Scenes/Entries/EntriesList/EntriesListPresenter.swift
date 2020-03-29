//
//  EntriesListPresenter.swift
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

protocol EntriesListPresentationLogic {
    func presentLoad(response: EntriesList.Load.Response)
    func inject(formattingWorker: EntriesListFormattingWorker)
}

final class EntriesListPresenter: EntriesListPresentationLogic {
    weak var viewController: EntriesListDisplayLogic?
    private var formattingWorker: EntriesListFormattingWorker?
    
    // MARK: Do something
    
    func presentLoad(response: EntriesList.Load.Response) {
        let entries = response.entries
        let cellViewModel = formattingWorker?.formatEntries(entries) ?? []
        
        let title = "entries_list_data_section_title".localized.uppercased()
        
        let viewModel = EntriesList.Load.ViewModel(items: [EntriesList.SectionViewModel(title: title, items: cellViewModel)])
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func inject(formattingWorker: EntriesListFormattingWorker) {
        self.formattingWorker = formattingWorker
    }
}

protocol EntriesListFormattingWorker {
    func formatEntries(_ entries: [AbstractEntry]) -> [EntriesList.CellViewModel]
}

final class EntriesListCarbsFormattingWorker: EntriesListFormattingWorker {
    
    func formatEntries(_ entries: [AbstractEntry]) -> [EntriesList.CellViewModel] {
        var cellViewModels: [EntriesList.CellViewModel] = []
        
        entries.forEach { (entry) in
            var value = ""

            value = String(format: "%.02f g", (entry as! CarbEntry).amount)

            let date = DateFormatter.localizedString(from: entry.date ?? Date(), dateStyle: .short, timeStyle: .short)

            cellViewModels.append(
                EntriesList.CellViewModel(value: value,
                                     date: date)
            )
        }
        
        return cellViewModels
    }
}

final class EntriesListBolusFormattingWorker: EntriesListFormattingWorker {
    
    func formatEntries(_ entries: [AbstractEntry]) -> [EntriesList.CellViewModel] {
        var cellViewModels: [EntriesList.CellViewModel] = []
        
        entries.forEach { (entry) in
            var value = ""

            value = String(format: "%.02f U", (entry as! BolusEntry).amount)

            let date = DateFormatter.localizedString(from: entry.date ?? Date(), dateStyle: .short, timeStyle: .short)

            cellViewModels.append(
                EntriesList.CellViewModel(value: value,
                                     date: date)
            )
        }
        
        return cellViewModels
    }
}
