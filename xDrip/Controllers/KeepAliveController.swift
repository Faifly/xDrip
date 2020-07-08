//
//  KeepAliveController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 03.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AVKit

final class KeepAliveController: NSObject {
    private var player: AVAudioPlayer?
    private var task = UIBackgroundTaskIdentifier(rawValue: 0)
    
    override init() {
        super.init()
        
        setupTask()
    }
    
    // MARK: Setup background task for endless background mode
    private func setupTask() {
        task = UIApplication.shared.beginBackgroundTask(withName: "silence_sound_task") { [weak self] in
            self?.restartTask()
        }
        
        do {
            guard let path = Bundle.main.path(forResource: "500ms-of-silence", ofType: ".mp3") else { return }
            let url = URL(fileURLWithPath: path)
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
        } catch {
            LogController.log(message: "Cannot instantiate audioPlayer", type: .error, error: error)
        }

        player?.play()
    }
    
    func restartTask() {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
        setupTask()
    }
}

// MARK: - AVAudioPlayerDelegate
extension KeepAliveController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        restartTask()
    }
}
