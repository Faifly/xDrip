//
//  UploadRequest.swift
//  xDrip
//
//  Created by Artem Kalmykov on 10.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct UploadRequest {
    let request: URLRequest
    let itemID: String
}

extension UploadRequest: Equatable {
    static func == (lhs: UploadRequest, rhs: UploadRequest) -> Bool {
        return lhs.itemID == rhs.itemID
    }
}
