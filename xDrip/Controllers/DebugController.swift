//
//  DebugController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 06.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import RealmSwift

final class DebugController {
    static let debugLogWindowID = "Debug Log"
    static let shared = DebugController()
    
    var logSubscriber: (() -> Void)?
    
    private init() {}
    
    private let maxLogSize = 1000
    private(set) var logs: [String] = []
    
    func showLogWindow() {
        UIApplication.shared.requestSceneSessionActivation(
            nil,
            userActivity: NSUserActivity(activityType: DebugController.debugLogWindowID),
            options: nil,
            errorHandler: nil
        )
    }
    
    func log(message: StaticString, args: [CVarArg]) {
        let date = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let message = String(format: "[\(date)] \(message)", arguments: args)
        logs.append(message)
        if logs.count == maxLogSize {
            logs.removeFirst()
        }
        logSubscriber?()
    }
    
    func purgeDatabase() {
        Realm.shared.safeWrite {
            Realm.shared.deleteAll()
        }
        exit(0)
    }
}
