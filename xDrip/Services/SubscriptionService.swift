//
//  SubscriptionService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol SubscriptionService {
    associatedtype Data
    typealias ListenerCallback = (Data) -> Void
    
    func subscribe(listener: AnyHashable, callback: @escaping ListenerCallback)
    func unsubscribe(listener: AnyHashable)
}

class AbstractSubscriptionService<T>: SubscriptionService {
    typealias Data = T
    
    private var listeners: [AnyHashable: ListenerCallback] = [:]
    
    func subscribe(listener: AnyHashable, callback: @escaping ListenerCallback) {
        listeners[listener] = callback
    }
    
    func unsubscribe(listener: AnyHashable) {
        listeners.removeValue(forKey: listener)
    }
}
