//
//  ViewController.m
//  icdab_lock
//
//  Created by Faisal Memon on 20/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSLock* criticalSectionLock;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useSemaphoreApi];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)useSemaphoreApi {
    dispatch_semaphore_t aSemaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(aSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(aSemaphore);
}

- (void)useLockingApi {
    criticalSectionLock = [[NSLock alloc] init];
    [criticalSectionLock unlock];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->criticalSectionLock unlock];
    });}

@end
