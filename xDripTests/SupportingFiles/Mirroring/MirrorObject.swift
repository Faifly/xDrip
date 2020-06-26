//
//  MirrorObject.swift
//  xDripTests
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

class MirrorObject {
    let mirror: Mirror
    
    init(reflecting: Any) {
        self.mirror = Mirror(reflecting: reflecting)
    }
    
    func extract<T>(variableName: StaticString = #function) -> T? {
        return mirror.descendant("\(variableName)") as? T
    }
}
