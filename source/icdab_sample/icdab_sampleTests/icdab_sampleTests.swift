//
//  icdab_sampleTests.swift
//  icdab_sampleTests
//
//  Created by Faisal Memon on 10/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import XCTest
@testable import icdab_sample

class icdab_sampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getFirstOctectAsInt(_ macAddress: String) -> Int {
        let firstOctect = macAddress.split(separator: ":").first!
        let firstOctectAsNumber = Int(String(firstOctect))!
        return firstOctectAsNumber
    }

    func testMacAddressNotNil() {
        let macAddress = MacAddress().getMacAddress()
        XCTAssertNotNil(macAddress)
    }
    
    func testMacAddressIsNotRandom() {
        let macAddressFirst = MacAddress().getMacAddress()
        let macAddressSecond = MacAddress().getMacAddress()
        XCTAssert(macAddressFirst == macAddressSecond)
    }
    
    func testMacAddressIsUnicast() {
        let macAddress = MacAddress().getMacAddress()!
        let firstOctect = getFirstOctectAsInt(macAddress)
        XCTAssert(0 == (firstOctect & 1))
    }
    
    func testMacAddressIsGloballyUnique() {
        let macAddress = MacAddress().getMacAddress()!
        let firstOctect = getFirstOctectAsInt(macAddress)
        XCTAssert(0 == (firstOctect & 2))
    }
    
}
