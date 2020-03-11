//
//  GlucoseDataService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol GlucoseDataService: SubscriptionService where Data == GlucoseData {}

final class GlucoseDataRealService: AbstractSubscriptionService<GlucoseData>, GlucoseDataService {
    let shared = GlucoseDataRealService()
}

final class GlucodeDataMockService: AbstractSubscriptionService<GlucoseData>, GlucoseDataService {
    let shared = GlucodeDataMockService()
}
