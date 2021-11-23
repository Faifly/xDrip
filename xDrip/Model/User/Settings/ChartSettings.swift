//
//  ChartSettings.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class ChartSettings: Object {
    enum BasalDisplayMode: Int, CaseIterable {
        case onTop
        case onBottom
        case notShown
        
        static let `default`: BasalDisplayMode = .onTop
    }
    
    @objc private(set) dynamic var showActiveInsulin: Bool = true
    @objc private(set) dynamic var showActiveCarbs: Bool = true
    @objc private(set) dynamic var showData: Bool = true
    @objc private dynamic var rawBasalDisplayMode: Int = BasalDisplayMode.default.rawValue
    @objc private(set) dynamic var selectedTimeLine: Int = 1
    
    private(set) var basalDisplayMode: BasalDisplayMode {
        get {
            return BasalDisplayMode(rawValue: rawBasalDisplayMode) ?? .default
        }
        set {
            rawBasalDisplayMode = newValue.rawValue
        }
    }
    
    func updateShowActiveInsulin(_ show: Bool) {
        Realm.shared.safeWrite {
            self.showActiveInsulin = show
        }
    }
    
    func updateShowActiveCarbs(_ show: Bool) {
        Realm.shared.safeWrite {
            self.showActiveCarbs = show
        }
    }
    
    func updateShowData(_ show: Bool) {
        Realm.shared.safeWrite {
            self.showData = show
        }
    }
    
    func updateBasalDispalyMode(_ mode: BasalDisplayMode) {
        Realm.shared.safeWrite {
            self.basalDisplayMode = mode
        }
    }
    
    func updateSelectedTimeLine(_ hours: Int) {
        Realm.shared.safeWrite {
            self.selectedTimeLine = hours
        }
    }
}
