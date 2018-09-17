//
//  icdab_cycleTests.swift
//  icdab_cycleTests
//
//  Created by Faisal Memon on 14/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import XCTest
@testable import icdab_cycle

class icdab_cycleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetainCycleLeak() {
        let vc = ViewController()
        vc.createRetainCycleLeak()
    }
    
}
