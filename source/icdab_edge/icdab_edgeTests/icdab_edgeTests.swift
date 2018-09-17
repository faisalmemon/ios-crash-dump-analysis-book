//
//  icdab_edgeTests.swift
//  icdab_edgeTests
//
//  Created by Faisal Memon on 09/09/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import XCTest
@testable import icdab_edge

class icdab_edgeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCorruptMalloc() {
        let crash = Crash()
        crash.corruptMalloc()
    }
    
    func testOverReleasedObject() {
        let crash = Crash()
        crash.overReleasedObject()
    }
    
    func testOvershootAllocated() {
        let crash = Crash()
        crash.overshootAllocated()
    }
    
    func testUnitializedMemory() {
        let crash = Crash()
        crash.uninitializedMemory()
    }
    
    func testUseAfterFree() {
        let crash = Crash()
        crash.useAfterFree()
    }
}
