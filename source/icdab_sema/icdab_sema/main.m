//
//  main.m
//  icdab_sema
//
//  Created by Faisal Memon on 20/07/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <Foundation/Foundation.h>

void use_sema() {
    dispatch_semaphore_t aSemaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(aSemaphore, DISPATCH_TIME_FOREVER);
    // dispatch_semaphore_signal(aSemaphore);
    dispatch_release(aSemaphore);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        use_sema();
    }
    return 0;
}
