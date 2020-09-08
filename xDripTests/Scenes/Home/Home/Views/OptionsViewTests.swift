//
//  OptionsViewTests.swift
//  xDripTests
//
//  Created by Dmitry on 07.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

@testable import xDrip
import XCTest

final class OptionsViewTests: XCTestCase {
    var sut: OptionsView?
    
    override func setUp() {
        super.setUp()
        sut = OptionsView.instantiate()
    }
    
    func testOptionsViewSetup() throws {
        let view = try XCTUnwrap(sut)
        let mirror = OptionsViewMirror(view: view)
        XCTAssertEqual(mirror.allTrainingsTilteLabel?.text, Option.allTrainings.title)
        XCTAssertEqual(mirror.allBasalsTitleLabel?.text, Option.allBasals.title)
        
        var selectedOption: Option?
        view.itemSelectionHandler = { option in
            selectedOption = option
        }
        
        view.onAllBasalTapped(sender: UITapGestureRecognizer())
        let option = try XCTUnwrap(selectedOption)
        XCTAssertEqual(option, Option.allBasals)
        
        view.onAllTrainingsTapped(sender: UITapGestureRecognizer())
        let option2 = try XCTUnwrap(selectedOption)
        XCTAssertEqual(option2, Option.allTrainings)
    }
}
