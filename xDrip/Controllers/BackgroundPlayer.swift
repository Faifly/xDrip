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
                                               selector: #selector(interruptedAudio),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        self.playAudio()
    }
    
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        player.stop()
    }
    
    @objc fileprivate func interruptedAudio(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification, let info = notification.userInfo {
            let state = info[AVAudioSessionInterruptionTypeKey] as? NSNumber
            if state?.intValue == 1 { playAudio() }
        }
    }
    
    fileprivate func playAudio() {
        do {
            guard let path = Bundle.main.path(forResource: "500ms-of-silence", ofType: ".mp3") else { return }
            let alertSound = URL(fileURLWithPath: path)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                            options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try self.player = AVAudioPlayer(contentsOf: alertSound)
            self.player.numberOfLoops = -1
            self.player.volume = 0.01
            self.player.prepareToPlay()
            self.player.play()
        } catch { print(error) }
    }
}
