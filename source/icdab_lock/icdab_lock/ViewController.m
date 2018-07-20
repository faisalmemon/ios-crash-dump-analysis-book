//
//  ViewController.m
//  icdab_lock
//
//  Created by Faisal Memon on 20/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ViewController smthPressed:self];
}

// Without the "static" keyword compile fails
static inline void fakeStartTimers() {
    int x = 0;
    int y = 0;
    printf("x and y are %d %d", x, y);
}

+ (void)smthPressed:(id) caller
{
    fakeStartTimers();
}

@end

