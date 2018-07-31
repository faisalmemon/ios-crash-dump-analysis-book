//
//  icdab_wrapUITests.swift
//  icdab_wrapUITests
//
//  Created by Faisal Memon on 20/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import XCTest

class icdab_wrapUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCrash() {
        let app = XCUIApplication()
        print(app.debugDescription)
        let plutoButton = app.buttons.element(matching: .button, identifier: "Show Pluto")
        plutoButton.tap()
        let backButton = app.navigationBars.buttons.element(matching: .button, identifier: "Back")
        backButton.tap()
        sleep(3)
    }
}
