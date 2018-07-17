//
//  icdab_planetsTests.m
//  icdab_planetsTests
//
//  Created by Faisal Memon on 16/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PlanetModel.h"

@interface icdab_planetsTests : XCTestCase

@end

@implementation icdab_planetsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlutoCanBeAdded {
    PlanetModel *model = [[PlanetModel alloc] init];
    XCTAssertNil(model); // it wanted Pluto to exist
    
    
}

@end
