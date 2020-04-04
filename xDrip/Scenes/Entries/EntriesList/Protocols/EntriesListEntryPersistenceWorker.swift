//
//  EntriesListEntryPersistenceWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol EntriesListEntryPersistenceWorker {
    func fetchEntries() -> [AbstractEntry]
    func deleteEntry(_ index: Int)
}
