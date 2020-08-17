//
//  URL+Custom.swift
//  xDrip
//
//  Created by Artem Kalmykov on 14.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension URL {
    func safeAppendingPathComponent(_ component: String) -> URL {
        if absoluteString.hasSuffix("/") && component.hasPrefix("/") {
            let index = component.index(component.startIndex, offsetBy: 1)
            return appendingPathComponent(String(component.suffix(from: index)))
        }
        
        return appendingPathComponent(component)
    }
}
