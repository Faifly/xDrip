//
//  AudioController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioController {
    static let shared = AudioController()
    
    private var audioPlayer = AVAudioPlayer()
    
    func playSoundFile(_ fileName: String) {
        let fileNameParts = fileName.split(separator: ".").map({ String($0) })
        let name = fileNameParts[0]
        let type = fileNameParts[1]
        
        guard let soundFilePath = Bundle.main.path(forResource: name, ofType: type) else { return }
        let url = URL(fileURLWithPath: "\(soundFilePath)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            LogController.log(message: "Failed to instantiate audio player", type: .error, error: error)
        }
    }
}
