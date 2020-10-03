//
//  icdab_cameraUITests.swift
//  icdab_cameraUITests
//
//  Created by Faisal Memon on 03/10/2020.
//

import XCTest

class icdab_cameraUITests: XCTestCase {

    func testTakePhoto() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Choose Picture"].tap()
    }

    
}
