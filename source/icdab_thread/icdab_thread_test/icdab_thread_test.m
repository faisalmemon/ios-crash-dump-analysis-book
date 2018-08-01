//
//  icdab_thread_test.m
//  icdab_thread_test
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface icdab_thread_test : XCTestCase

@end

@implementation icdab_thread_test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThreadSetState {
    start_threads();
}
@end
