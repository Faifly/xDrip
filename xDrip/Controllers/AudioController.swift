//
//  AudioController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer
import UserNotifications

final class AudioController: NSObject {
    static let shared = AudioController()
    
    private var audioPlayer = AVAudioPlayer()
    private var previousVolume: Float = 0.0
    
    func playSoundFile(_ fileName: String) {
        guard let url = getFileURL(for: fileName) else { return }
        playFile(with: url)
        
        if let alert = User.current.settings.alert {
            setupMuteOverriden(alert.isMuteOverriden)
            setupVolume(
                isSystemVolumeOverriden: alert.isSystemVolumeOverriden,
                overridenVolume: alert.volume
            )
        }
    }
    
    func playFileFromNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        guard let soundFileName = userInfo["soundFileName"] as? String,
            let url = getFileURL(for: soundFileName) else {
            return
        }
        playFile(with: url)
        
        if let isMuteOverriden = userInfo["isMuteOverriden"] as? Bool {
            setupMuteOverriden(isMuteOverriden)
        }
        
        if let isSystemVolumeOverriden = userInfo["isSystemVolumeOverriden"] as? Bool,
            let volume = userInfo["overridenVolume"] as? Float {
            setupVolume(
                isSystemVolumeOverriden: isSystemVolumeOverriden,
                overridenVolume: volume
            )
        }
    }
    
    private func playFile(with url: URL) {
        audioPlayer.stop()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            LogController.log(message: "Failed to instantiate audio player", type: .error, error: error)
        }
        
        audioPlayer.play()
    }
    
    private func setupVolume(isSystemVolumeOverriden: Bool, overridenVolume: Float) {
        if isSystemVolumeOverriden {
            previousVolume = MPVolumeView.volume ?? 0.5
            MPVolumeView.setVolume(overridenVolume)
        }
    }
    
    private func setupMuteOverriden(_ isOverriden: Bool) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(
                isOverriden ? .playback : .soloAmbient//,
//                mode: .default,
//                options: [.duckOthers, .defaultToSpeaker]
            )
            
            do {
                try session.setActive(true)
            } catch {
                LogController.log(message: "Failed to activate audio session", type: .error, error: error)
            }
//            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            LogController.log(message: "Failed to configurate audio session", type: .error, error: error)
            print("AVAudioSession error: \(error)")
        }
    }
    
    private func getFileURL(for fileName: String) -> URL? {
        let fileNameParts = fileName.split(separator: ".").map({ String($0) })
        
        guard fileNameParts.count > 1 else {
            return nil
        }
        
        let name = fileNameParts[0]
        let type = fileNameParts[1]
        
        guard let soundFilePath = Bundle(identifier: "com.faifly.xDrip")?.path(forResource: name, ofType: type) else { return nil }
        return URL(fileURLWithPath: "\(soundFilePath)")
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}

private extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        // Need to use the MPVolumeView in order to change volume, but don't care about UI set so frame to .zero
        let volumeView = MPVolumeView(frame: .zero)
        // Search for the slider
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        // Update the slider value with the desired volume.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
        // Optional - Remove the HUD
//        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
//            volumeView.alpha = 0.000001
//            window.addSubview(volumeView)
//        }
    }
    
    static var volume: Float? {
        let volumeView = MPVolumeView(frame: .zero)
        // Search for the slider
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        return slider?.value
    }
}

extension AudioController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if User.current.settings.alert?.isSystemVolumeOverriden == true {
            MPVolumeView.setVolume(previousVolume)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            LogController.log(message: "Failed to deactivate audio session", type: .error, error: error)
        }
    }
}
