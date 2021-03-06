//
//  NightscoutServiceMirror.swift
//  xDripTests
//
//  Created by Dmitry on 15.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

@testable import xDrip

// swiftlint:disable discouraged_optional_collection

final class NightscoutServiceMirror: MirrorObject {
    init(object: NightscoutService) {
        super.init(reflecting: object)
    }
    
    var requestQueue: [UploadRequest]? {
        return extract()
    }
}
