//
//  main.m
//  icdab_thread
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pthread_helper.h"

void *print_usage(int argc, const char *argv[]) {
    printf("Usage: %s serial|parallel num_tasks\n", argv[0]);
    exit(1);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        start_threads();
    }
    return 0;
}
