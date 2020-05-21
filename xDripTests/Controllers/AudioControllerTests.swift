//
//  AudioControllerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class AudioControllerTest: XCTestCase {
    func testWrongFileName() {
        // Given
        let wrongFileName = "File name"
        
        // When
        AudioController.shared.playSoundFile(wrongFileName)
        
        // Then
    }
    
    func testSoundFileNotInMainBundle() {
        // Given
        let fileName = "SoundFile.caf"
        
        // When
        AudioController.shared.playSoundFile(fileName)
        
        // Then
    }
}
