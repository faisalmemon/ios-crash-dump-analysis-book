//
//  icdab_memTests.swift
//  icdab_memTests
//
//  Created by Faisal Memon on 19/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

import XCTest
@testable import icdab_mem

class icdab_memTests: XCTestCase {
    
    var downloadExpectation: XCTestExpectation?
    var error: NSError?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownload() {
        downloadExpectation = expectation(description: "DownloadPhoto")
        let helper = DownloadHelper(urlString: "https://solarsystem.nasa.gov/system/downloadable_items/1192_pluto_natural_color_20150714.png")
        helper.downloadDelegate = self
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDownloadFailure() {
        downloadExpectation = expectation(description: "DownloadFailure")
        let helper = DownloadHelper(urlString: "https://solarsystem.nasa.gov/system/downloadable_items/1192_pluto_natural_color_20150714.XXX.png")
        helper.downloadDelegate = self
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssert(self.error != nil)
    }
    
}

extension icdab_memTests: DownloadDelegate {
    func imageDownloaded(_ image: UIImage) {
        downloadExpectation?.fulfill()
    }
    
    func downloadFailed(_ error: NSError) {
        self.error = error
        downloadExpectation?.fulfill()
    }
    
    
}
