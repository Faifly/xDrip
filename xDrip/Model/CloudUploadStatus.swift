//
//  CloudUploadStatus.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CloudUploadStatus: Int {
    case notApplicable
    case notUploaded
    case modified
    case uploaded
    case waitingForDeletion
}
