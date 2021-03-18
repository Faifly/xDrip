//
//  BackgroundPlayer.swift
//  xDrip
//
//  Created by Dmitry on 19.03.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

import AVFoundation

class BackgroundPlayer {
    var player = AVAudioPlayer()
    var timer = Timer()
    
    func startBackgroundTask() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        self.playAudio()
    }
    
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        player.stop()
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began: break
        case .ended: playAudio()
        default: break
        }
    }
    
    fileprivate func playAudio() {
        do {
            guard let path = Bundle.main.path(forResource: "500ms-of-silence", ofType: ".mp3") else { return }
            let sound = URL(fileURLWithPath: path)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                            options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try self.player = AVAudioPlayer(contentsOf: sound)
            self.player.numberOfLoops = -1
            self.player.volume = 0.01
            self.player.prepareToPlay()
            self.player.play()
        } catch { LogController.log(message: "Can not play audio", type: .error, error: error) }
    }
}
