//
//  main.m
//  icdab_sema_ios
//
//  Created by Faisal Memon on 31/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


void use_sema() {
    dispatch_semaphore_t aSemaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(aSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(aSemaphore);
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        use_sema();

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
