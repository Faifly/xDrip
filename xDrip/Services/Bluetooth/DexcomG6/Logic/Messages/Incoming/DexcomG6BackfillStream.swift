//
//  DexcomG6BackfillStream.swift
//  xDrip
//
//  Created by Ivan Skoryk on 02.11.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class DexcomG6BackfillStream {
    struct Backsie {
        let glucose: Int
        let trend: Int
        let dexTime: Int
    }
    
    var data = Data([0, 0])
    private var lastSequence = 0
    
    func push(_ packet: Data) {
        guard !packet.isEmpty else { return }
        let thisSequence = packet[0]
        
        if thisSequence == lastSequence + 1 {
            lastSequence += 1
            
            for idx in 2 ..< packet.count {
                guard data.count < 1000 else {
                    LogController.log(message: "[BackfillStream]: Reached limit for backfill stream size", type: .debug)
                    return
                }
                data.append(packet[idx])
            }
        } else {
            LogController.log(
                message: "[BackfillStream]: Received backfill packet out of sequence: %d vs %d",
                type: .debug,
                thisSequence,
                lastSequence
            )
        }
    }
    
    func decode() -> [Backsie] {
        var backsies: [Backsie] = []
        
        var idx = 0
        while idx < data.count {
            let dexTime = Data(data[idx ..< idx + 4]).to(Int.self)
            idx += 4
            
            let glucose = Data(data[idx ..< idx + 2]).to(Int16.self)
            idx += 2
            
            let type = data[idx]
            idx += 1
            
            let trend = data[idx]
            idx += 1
            
            if let state = DexcomG6CalibrationState(rawValue: type) {
                switch state {
                case .okay, .needsCalibration:
                    if dexTime != 0 {
                        backsies.append(
                            Backsie(glucose: Int(glucose), trend: Int(trend), dexTime: dexTime)
                        )
                    }
                default:
                    continue
                }
            } else {
                LogController.log(
                    message: "[BackfillStream] Encountered backfill data we don't recognise: %d %d %d",
                    type: .debug,
                    type,
                    glucose,
                    trend
                )
            }
        }
        
        return backsies
    }
}
