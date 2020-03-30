//
//  EntriesListTableController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 29.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import UIKit

final class EntriesListTableController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private var data: [EntriesList.SectionViewModel] = []
    
    var didDeleteEntry: ((IndexPath) -> ())?
    var didSelectEntry: ((IndexPath) -> ())?
    
    func reload(with data: [EntriesList.SectionViewModel]) {
        self.data = data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(ofType: EntriesListTableViewCell.self, for: indexPath)
       let cellData = data[indexPath.section].items[indexPath.row]
       
       cell.configure(withViewModel: cellData)
       
       return cell
   }
       
   func numberOfSections(in tableView: UITableView) -> Int {
       return data.count
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return data[section].items.count
   }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            didDeleteEntry?(indexPath)
            data[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        didSelectEntry?(indexPath)
    }
}
