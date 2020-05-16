//
//  EditTrainingRouterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class EditTrainingRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: EditTrainingRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = EditTrainingRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.finishEncoding()
        let data = archiver.encodedData
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            fatalError()
        }
        guard let spy = ViewControllerSpy(coder: unarchiver) else {
            fatalError()
        }
        return spy
    }
    
    // MARK: Test doubles
    
    final class ViewControllerSpy: EditTrainingViewController {
    }
    
    // MARK: Tests
}
