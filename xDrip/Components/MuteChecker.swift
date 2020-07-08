//
//  MuteChecker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

@objcMembers
final class MuteChecker: NSObject {
    typealias MuteNotificationCompletion = ((_ mute: Bool) -> Void)

    // MARK: Properties
    /// Shared instance
    static let shared = MuteChecker()

    /// Sound ID for mute sound
    private let soundUrl = MuteChecker.muteSoundUrl

    /// Should notify every second or only when changes?
    /// True will notify every second of the state, false only when it changes
    var alwaysNotify = true

    /// Notification handler to be triggered when mute status changes
    /// Triggered every second if alwaysNotify=true, otherwise only when it switches state
    var notify: MuteNotificationCompletion?

    /// Current mute state
    private(set) var isMute = false

    /// Silent sound (0.5 sec)
    private var soundId: SystemSoundID = 0

    /// Time difference between start and finish of mute sound
    private var interval: TimeInterval = 0

    // MARK: Resources

    /// Mute sound url path
    private static var muteSoundUrl: URL {
        guard let muteSoundUrl = Bundle.main.url(forResource: "mute", withExtension: "aiff") else {
            fatalError("mute.aiff not found")
        }
        return muteSoundUrl
    }

    // MARK: Init
    func checkMute(_ completion: @escaping MuteNotificationCompletion) {
        notify = completion
        self.soundId = 1

        if AudioServicesCreateSystemSoundID(self.soundUrl as CFURL, &self.soundId) == kAudioServicesNoError {
            var yes: UInt32 = 1
            AudioServicesSetProperty(kAudioServicesPropertyIsUISound,
                                     UInt32(MemoryLayout.size(ofValue: self.soundId)),
                                     &self.soundId,
                                     UInt32(MemoryLayout.size(ofValue: yes)),
                                     &yes)
            playSound()
        } else {
            print("Failed to setup sound player")
            self.soundId = 0
        }
    }

    deinit {
        if self.soundId != 0 {
            AudioServicesRemoveSystemSoundCompletion(self.soundId)
            AudioServicesDisposeSystemSoundID(self.soundId)
        }
    }

    // MARK: Methods

    /// If not paused, playes mute sound
    private func playSound() {
        self.interval = Date.timeIntervalSinceReferenceDate
        AudioServicesPlaySystemSoundWithCompletion(self.soundId) { [weak self] in
            self?.soundFinishedPlaying()
        }
    }

    /// Called when AudioService finished playing sound
    private func soundFinishedPlaying() {
        let elapsed = Date.timeIntervalSinceReferenceDate - self.interval
        let isMute = elapsed < 0.1

        DispatchQueue.main.async {
            self.notify?(isMute)
        }
    }
}
