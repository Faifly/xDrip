//
//  UITableView+Tests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
@testable import xDrip

extension UITableView {
    func getCell<T: UITableViewCell>(of type: T.Type, at indexPath: IndexPath) -> T? {
        return dataSource?.tableView(self, cellForRowAt: indexPath) as? T
    }
    
    func callDidSelect(at indexPath: IndexPath) {
        delegate?.tableView?(self, didSelectRowAt: indexPath)
    }
}
