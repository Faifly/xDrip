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
        playAudio()
    }
    
    fileprivate func playAudio() {
        do {
            guard let path = Bundle.main.path(forResource: "500ms-of-silence", ofType: ".mp3") else { return }
            let sound = URL(fileURLWithPath: path)
            let songData = try NSData(contentsOf: sound, options: NSData.ReadingOptions.mappedIfSafe)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: songData as Data)
            player.numberOfLoops = -1
            player.volume = 0.01
            player.prepareToPlay()
            player.play()
        } catch { LogController.log(message: "Failed to play audio", type: .error, error: error) }
    }
}
